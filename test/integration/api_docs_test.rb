require "test_helper"

class ApiDocsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @note = notes(:one)
    @category = categories(:one)
    @spec = JSON.parse(File.read(Rails.root.join("swagger/v1/openapi.json")))
  end

  # Swagger UI

  test "renders Swagger UI at /api-docs" do
    get "/api-docs"
    assert_response :moved_permanently

    follow_redirect!
    assert_response :success
    assert_includes response.body, "swagger-ui"
    assert_includes response.body, "SwaggerUIBundle"
  end

  # OpenAPI spec

  test "serves the OpenAPI spec as JSON" do
    get "/api-docs/v1/openapi.json"
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "spec has a valid OpenAPI structure" do
    assert_equal "3.0.3", @spec["openapi"]
    assert_equal "Notes API", @spec.dig("info", "title")
    assert_equal "/", @spec.dig("servers", 0, "url")
  end

  test "spec documents every API path" do
    expected_paths = [
      "/signup",
      "/session",
      "/passwords",
      "/passwords/{token}",
      "/api/v1/notes",
      "/api/v1/notes/{id}",
      "/api/v1/categories",
      "/api/v1/categories/{id}"
    ]

    expected_paths.each do |path|
      assert @spec["paths"].key?(path), "expected spec to document #{path}"
    end
  end

  test "request body schemas match the parameter wrapping the API expects" do
    wrapped = [
      [ "post", "/signup", "user" ],
      [ "post", "/api/v1/notes", "note" ],
      [ "put", "/api/v1/notes/{id}", "note" ],
      [ "patch", "/api/v1/notes/{id}", "note" ],
      [ "post", "/api/v1/categories", "category" ],
      [ "put", "/api/v1/categories/{id}", "category" ],
      [ "patch", "/api/v1/categories/{id}", "category" ]
    ]

    wrapped.each do |method, path, key|
      schema = deref(@spec.dig("paths", path, method, "requestBody", "content", "application/json", "schema"))
      assert schema["properties"].key?(key),
             "expected #{method.upcase} #{path} request body to wrap params in #{key}"
    end

    flat = [
      [ "post", "/session" ],
      [ "post", "/passwords" ],
      [ "patch", "/passwords/{token}" ]
    ]

    flat.each do |method, path|
      schema = deref(@spec.dig("paths", path, method, "requestBody", "content", "application/json", "schema"))
      keys = schema["properties"].keys
      refute (keys & %w[user note category]).any?,
             "expected #{method.upcase} #{path} request body to be flat (got #{keys})"
    end
  end

  test "signup works with the exact request body documented in the spec" do
    body = @spec.dig("paths", "/signup", "post", "requestBody", "content", "application/json", "schema", "example")

    post "/signup", params: body.to_json, headers: { "Content-Type" => "application/json" }

    assert_response :created
    assert_equal "me@example.com", JSON.parse(response.body)["email_address"]
  end

  test "spec documents protected operations with the cookie auth scheme" do
    protected_ops = [
      [ "delete", "/session" ],
      [ "get", "/api/v1/notes" ],
      [ "post", "/api/v1/notes" ],
      [ "get", "/api/v1/notes/{id}" ],
      [ "put", "/api/v1/notes/{id}" ],
      [ "patch", "/api/v1/notes/{id}" ],
      [ "delete", "/api/v1/notes/{id}" ],
      [ "get", "/api/v1/categories" ],
      [ "post", "/api/v1/categories" ],
      [ "get", "/api/v1/categories/{id}" ],
      [ "put", "/api/v1/categories/{id}" ],
      [ "patch", "/api/v1/categories/{id}" ],
      [ "delete", "/api/v1/categories/{id}" ]
    ]

    protected_ops.each do |method, path|
      op = @spec.dig("paths", path, method)
      assert op["security"].any? { |s| s.key?("cookieAuth") },
             "expected #{method.upcase} #{path} to require cookieAuth"
    end
  end

  # Docs stay in sync with the actual API behavior

  test "signup scenarios match documented responses" do
    run_scenario(:post, "/signup", sign_in: false, params: { user: { email_address: "x@example.com", password: "password", password_confirmation: "password" } })
    assert_response_matches_spec

    run_scenario(:post, "/signup", sign_in: false, params: { user: {} })
    assert_response_matches_spec
  end

  test "session scenarios match documented responses" do
    run_scenario(:post, "/session", sign_in: false, params: { email_address: @user.email_address, password: "password" })
    assert_response_matches_spec

    run_scenario(:post, "/session", sign_in: false, params: { email_address: @user.email_address, password: "wrong" })
    assert_response_matches_spec
  end

  test "notes index scenarios match documented responses" do
    run_scenario(:get, "/api/v1/notes", sign_in: true, params: nil)
    assert_response_matches_spec

    run_scenario(:get, "/api/v1/notes", sign_in: false, params: nil)
    assert_response_matches_spec
  end

  test "categories index scenarios match documented responses" do
    run_scenario(:get, "/api/v1/categories", sign_in: true, params: nil)
    assert_response_matches_spec

    run_scenario(:get, "/api/v1/categories", sign_in: false, params: nil)
    assert_response_matches_spec
  end

  test "note lifecycle scenarios match documented responses" do
    run_scenario(:post, "/api/v1/notes", sign_in: true, params: { note: { title: "Criada", content: "Body", category_id: @category.id } })
    assert_response_matches_spec
    note_id = JSON.parse(response.body)["id"]

    run_scenario(:get, "/api/v1/notes/#{note_id}", sign_in: true, params: nil)
    assert_response_matches_spec

    run_scenario(:patch, "/api/v1/notes/#{note_id}", sign_in: true, params: { note: { title: "Atualizada" } })
    assert_response_matches_spec

    run_scenario(:delete, "/api/v1/notes/#{note_id}", sign_in: true, params: nil)
    assert_response_matches_spec
  end

  test "note error scenarios match documented responses" do
    run_scenario(:post, "/api/v1/notes", sign_in: true, params: { note: { title: "Sem categoria", category_id: nil } })
    assert_response_matches_spec

    run_scenario(:get, "/api/v1/notes/-1", sign_in: true, params: nil)
    assert_response_matches_spec

    run_scenario(:patch, "/api/v1/notes/-1", sign_in: true, params: { note: { title: "X" } })
    assert_response_matches_spec
  end

  test "category lifecycle scenarios match documented responses" do
    run_scenario(:post, "/api/v1/categories", sign_in: true, params: { category: { title: "Nova" } })
    assert_response_matches_spec
    category_id = JSON.parse(response.body)["id"]

    run_scenario(:get, "/api/v1/categories/#{category_id}", sign_in: true, params: nil)
    assert_response_matches_spec

    run_scenario(:put, "/api/v1/categories/#{category_id}", sign_in: true, params: { category: { title: "Renomeada", slug: "renomeada" } })
    assert_response_matches_spec

    run_scenario(:delete, "/api/v1/categories/#{category_id}", sign_in: true, params: nil)
    assert_response_matches_spec
  end

  test "category error scenarios match documented responses" do
    run_scenario(:get, "/api/v1/categories/-1", sign_in: true, params: nil)
    assert_response_matches_spec

    run_scenario(:patch, "/api/v1/categories/-1", sign_in: true, params: { category: { title: "Ghost" } })
    assert_response_matches_spec
  end

  private

  def deref(schema)
    return schema unless schema["$ref"]

    name = schema["$ref"].delete_prefix("#/components/schemas/")
    @spec.dig("components", "schemas", name)
  end

  def run_scenario(method, path, sign_in:, params:)
    sign_in_as(@user) if sign_in

    send(method, path, params: params, as: :json)
    @spec_method = method
    @spec_path = spec_path_for(path)
  end

  # Strip concrete ids so they match the templated spec paths.
  def spec_path_for(path)
    segments = path.split("/")
    segments.map { |s| s.match?(/\A-?\d+\z/) ? "{id}" : s }.join("/")
  end

  def assert_response_matches_spec
    op = @spec.dig("paths", @spec_path, @spec_method.to_s)
    assert op, "expected spec to document #{@spec_method.upcase} #{@spec_path}"

    documented = op["responses"].keys.map(&:to_i)
    assert_includes documented, response.status,
                    "response #{response.status} for #{@spec_method.upcase} #{@spec_path} is not documented in the spec"
  end
end
