require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "create with valid credentials" do
    post session_url, params: { email_address: @user.email_address, password: "password" }, as: :json

    assert_response :success
    assert cookies[:session_id]
    json = JSON.parse(response.body)
    assert_equal "Signed in successfully.", json["message"]
  end

  test "create with invalid credentials" do
    post session_url, params: { email_address: @user.email_address, password: "wrong" }, as: :json

    assert_response :unauthorized
    assert_nil cookies[:session_id]
    json = JSON.parse(response.body)
    assert_equal "Invalid email address or password.", json["error"]
  end

  test "create with unknown user" do
    post session_url, params: { email_address: "missing@example.com", password: "password" }, as: :json

    assert_response :unauthorized
    assert_nil cookies[:session_id]
  end

  test "destroy destroys the current session" do
    sign_in_as(@user)

    assert_difference "Session.count", -1 do
      delete session_url, as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Signed out successfully.", json["message"]
  end

  test "destroy requires authentication" do
    delete session_url, as: :json
    assert_response :unauthorized
  end
end
