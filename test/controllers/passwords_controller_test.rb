require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "create sends password reset instructions" do
    post passwords_url, params: { email_address: @user.email_address }, as: :json

    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_response :success
  end

  test "create for an unknown user sends no mail" do
    assert_enqueued_emails 0 do
      post passwords_url, params: { email_address: "missing-user@example.com" }, as: :json
    end

    assert_response :success
  end

  test "update resets the password and destroys other sessions" do
    sign_in_as(@user)
    other_session = @user.sessions.create!

    assert_changes -> { @user.reload.password_digest } do
      put password_url(@user.password_reset_token), params: { password: "newpassword", password_confirmation: "newpassword" }, as: :json
    end

    assert_response :success
    assert_not Session.exists?(other_session.id)
  end

  test "update with mismatched passwords" do
    assert_no_changes -> { @user.reload.password_digest } do
      put password_url(@user.password_reset_token), params: { password: "newpassword", password_confirmation: "different" }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "update with invalid token" do
    put password_url("invalid token"), params: { password: "newpassword", password_confirmation: "newpassword" }, as: :json

    assert_response :bad_request
  end
end
