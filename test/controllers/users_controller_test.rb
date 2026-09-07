require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "signup with valid params" do
    assert_difference "User.count" do
      post signup_url,
           params: {
             user: {
               email_address: "new@example.com",
               password: "password",
               password_confirmation: "password"
             }
           },
           as: :json
    end

    assert_response :created
    assert cookies[:session_id]
    json = JSON.parse(response.body)
    assert_equal "new@example.com", json["email_address"]
    assert_not json.key?("password_digest")
  end

  test "signup normalizes email address" do
    post signup_url,
         params: {
           user: {
             email_address: "  NEW@EXAMPLE.COM ",
             password: "password",
             password_confirmation: "password"
           }
         },
         as: :json

    assert_response :created
    assert_equal "new@example.com", JSON.parse(response.body)["email_address"]
  end

  test "signup with mismatched password confirmation" do
    assert_no_difference "User.count" do
      post signup_url,
           params: {
             user: {
               email_address: "new@example.com",
               password: "password",
               password_confirmation: "different"
             }
           },
           as: :json
    end

    assert_response :unprocessable_entity
  end

  test "signup with duplicate email" do
    assert_no_difference "User.count" do
      post signup_url,
           params: {
             user: {
               email_address: users(:one).email_address,
               password: "password",
               password_confirmation: "password"
             }
           },
           as: :json
    end

    assert_response :unprocessable_entity
  end

  test "signup without password" do
    assert_no_difference "User.count" do
      post signup_url,
           params: { user: { email_address: "new@example.com" } },
           as: :json
    end

    assert_response :unprocessable_entity
  end
end
