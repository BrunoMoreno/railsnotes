class UsersController < ApplicationController
  allow_unauthenticated_access only: :create

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      render json: user_json(@user), status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end

  def user_json(user)
    { id: user.id, email_address: user.email_address, created_at: user.created_at }
  end
end
