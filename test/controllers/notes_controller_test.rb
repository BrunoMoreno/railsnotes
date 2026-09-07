require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @note = notes(:one)
    @category = categories(:one)
  end

  # GET /api/v1/notes

  test "should get index" do
    get notes_url, as: :json
    assert_response :success
  end

  test "index returns all notes as JSON array" do
    get notes_url, as: :json
    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_equal Note.count, json.length
  end

  test "index notes include expected keys" do
    get notes_url, as: :json
    json = JSON.parse(response.body)
    note = json.first
    assert note.key?("id")
    assert note.key?("title")
    assert note.key?("content")
    assert note.key?("is_public")
    assert note.key?("category_id")
  end

  # POST /api/v1/notes

  test "should create note" do
    assert_difference("Note.count") do
      post notes_url,
           params: {
             note: {
               title: "Nova nota",
               content: "Conteúdo de teste",
               is_public: true,
               category_id: @category.id
             }
           },
           as: :json
    end

    assert_response :created
  end

  test "create note returns the created note in response body" do
    post notes_url,
         params: {
           note: {
             title: "Nota com response",
             content: "Verificando body",
             is_public: false,
             category_id: @category.id
           }
         },
         as: :json

    json = JSON.parse(response.body)
    assert_equal "Nota com response", json["title"]
    assert_equal "Verificando body", json["content"]
    assert_equal false, json["is_public"]
    assert_equal @category.id, json["category_id"]
  end

  test "create note sets location header" do
    post notes_url,
         params: {
           note: {
             title: "Teste Location",
             content: "Header",
             category_id: @category.id
           }
         },
         as: :json

    assert response.headers["Location"].present?
  end

  test "allows creating note without title" do
    assert_difference("Note.count") do
      post notes_url,
           params: {
             note: {
               title: nil,
               content: "Sem título",
               category_id: @category.id
             }
           },
           as: :json
    end

    assert_response :created
  end

  test "should not create note without category" do
    assert_no_difference("Note.count") do
      post notes_url,
           params: {
             note: {
               title: "Sem categoria",
               content: "Conteúdo",
               category_id: nil
             }
           },
           as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should not create note with nonexistent category" do
    assert_no_difference("Note.count") do
      post notes_url,
           params: {
             note: {
               title: "Categoria fantasma",
               content: "Conteúdo",
               category_id: -1
             }
           },
           as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should return bad request for empty note params" do
    post notes_url,
         params: { note: {} },
         as: :json

    assert_response :bad_request
  end

  # GET /api/v1/notes/:id

  test "should get show" do
    get note_url(@note), as: :json
    assert_response :success
  end

  test "show returns correct note data" do
    get note_url(@note), as: :json
    json = JSON.parse(response.body)
    assert_equal @note.id, json["id"]
    assert_equal @note.title, json["title"]
    assert_equal @note.content, json["content"]
    assert_equal @note.category_id, json["category_id"]
  end

  test "should return not found for nonexistent note" do
    get note_url(id: -1), as: :json
    assert_response :not_found
  end
end
