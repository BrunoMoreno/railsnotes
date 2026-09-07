require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url, as: :json
    assert_response :success
  end

  test "index returns welcome message" do
    get root_url, as: :json
    json = JSON.parse(response.body)
    assert_equal "Welcome to the Notes API!", json["message"]
  end
end
