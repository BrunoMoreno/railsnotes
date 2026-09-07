require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "has secure password" do
    user = users(:one)
    assert_respond_to user, :authenticate
    assert_respond_to user, :password=
  end

  test "has many sessions" do
    user = users(:one)
    assert_respond_to user, :sessions
  end

  test "has many notes" do
    user = users(:one)
    assert_respond_to user, :notes
  end

  test "destroys dependent sessions" do
    user = User.create!(email_address: "dep@example.com", password: "password")
    user.sessions.create!
    user.sessions.create!

    assert_difference "Session.count", -2 do
      user.destroy!
    end
  end

  test "destroys dependent notes" do
    user = User.create!(email_address: "dep-notes@example.com", password: "password")
    category = categories(:one)
    Note.create!(title: "Note 1", content: "Body", category: category, user: user)

    assert_difference "Note.count", -1 do
      user.destroy!
    end
  end

  test "is invalid without email" do
    user = User.new(password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "is invalid with duplicate email" do
    users(:one)
    user = User.new(email_address: "one@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "is invalid without password" do
    user = User.new(email_address: "nopass@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "authenticates with valid password" do
    user = users(:one)
    assert_equal user, user.authenticate("password")
  end

  test "does not authenticate with invalid password" do
    user = users(:one)
    assert_not user.authenticate("wrong")
  end
end
