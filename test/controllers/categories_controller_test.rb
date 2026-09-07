require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = categories(:one)
    sign_in_as(@user)
  end

  # Authentication

  test "requires authentication for index" do
    sign_out
    get categories_url, as: :json
    assert_response :unauthorized
  end

  test "requires authentication for create" do
    sign_out
    post categories_url, params: { category: { title: "Teste" } }, as: :json
    assert_response :unauthorized
  end

  # GET /api/v1/categories

  test "should get index" do
    get categories_url, as: :json
    assert_response :success
  end

  test "index returns all categories as JSON array" do
    get categories_url, as: :json
    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_equal Category.count, json.length
  end

  test "index categories include expected keys" do
    get categories_url, as: :json
    json = JSON.parse(response.body)
    category = json.first
    assert category.key?("id")
    assert category.key?("title")
    assert category.key?("slug")
  end

  # POST /api/v1/categories

  test "should create category" do
    assert_difference("Category.count") do
      post categories_url,
           params: { category: { title: "Novo.slug", slug: "novo-slug" } },
           as: :json
    end

    assert_response :created
  end

  test "create category returns the created category in response body" do
    post categories_url,
         params: { category: { title: "Python", slug: "python" } },
         as: :json

    json = JSON.parse(response.body)
    assert_equal "Python", json["title"]
    assert json.key?("id")
    assert json.key?("slug")
  end

  test "create category sets location header" do
    post categories_url,
         params: { category: { title: "Go", slug: "go" } },
         as: :json

    assert response.headers["Location"].present?
  end

  test "should auto-generate slug on create" do
    post categories_url,
         params: { category: { title: "TypeScript" } },
         as: :json

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "typescript", json["slug"]
  end

  test "should return bad request for empty category params" do
    post categories_url,
         params: { category: {} },
         as: :json

    assert_response :bad_request
  end

  # GET /api/v1/categories/:id

  test "should show category" do
    get category_url(@category), as: :json
    assert_response :success
  end

  test "show returns correct category data" do
    get category_url(@category), as: :json
    json = JSON.parse(response.body)
    assert_equal @category.id, json["id"]
    assert_equal @category.title, json["title"]
    assert_equal @category.slug, json["slug"]
  end

  test "should return not found for nonexistent category" do
    get category_url(id: -1), as: :json
    assert_response :not_found
  end

  # PATCH /api/v1/categories/:id

  test "should update category" do
    patch category_url(@category),
          params: { category: { title: "Updated", slug: "updated" } },
          as: :json
    assert_response :success
  end

  test "update returns the updated category data" do
    patch category_url(@category),
          params: { category: { title: "Rust", slug: "rust" } },
          as: :json

    json = JSON.parse(response.body)
    assert_equal "Rust", json["title"]
    assert_equal "rust", json["slug"]
  end

  test "should auto-generate slug on update when title changes" do
    patch category_url(@category),
          params: { category: { title: "Elixir" } },
          as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "elixir", json["slug"]
  end

  test "update with empty title keeps existing slug" do
    patch category_url(@category),
          params: { category: { title: "" } },
          as: :json

    assert_response :success
    @category.reload
    assert_equal "", @category.title
    assert_equal "ruby-on-rails", @category.slug
  end

  test "should return not found for update on nonexistent category" do
    patch category_url(id: -1),
          params: { category: { title: "Ghost" } },
          as: :json
    assert_response :not_found
  end

  # DELETE /api/v1/categories/:id

  test "should destroy category" do
    assert_difference("Category.count", -1) do
      delete category_url(@category), as: :json
    end

    assert_response :no_content
  end

  test "destroy removes associated notes" do
    category = Category.create!(title: "To Delete", slug: "to-delete")
    Note.create!(title: "Note 1", content: "Body", category: category, user: @user)
    Note.create!(title: "Note 2", content: "Body", category: category, user: @user)

    assert_difference({ "Category.count" => -1, "Note.count" => -2 }) do
      delete category_url(category), as: :json
    end

    assert_response :no_content
  end

  test "should return not found for destroy on nonexistent category" do
    delete category_url(id: -1), as: :json
    assert_response :not_found
  end
end
