class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: :update
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { render json: { error: "Too many attempts. Try again later." }, status: :too_many_requests }

  def create
    if user = User.find_by(email_address: params[:email_address]&.downcase)
      PasswordsMailer.reset(user).deliver_later
    end

    render json: { message: "Password reset instructions sent (if user with that email address exists)." }, status: :ok
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      render json: { message: "Password has been reset." }, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: "Password reset link is invalid or has expired." }, status: :bad_request
  end
end
