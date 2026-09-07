class SessionsController < ApplicationController
  allow_unauthenticated_access only: :create
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { render json: { error: "Too many attempts. Try again later." }, status: :too_many_requests }

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      render json: { message: "Signed in successfully." }, status: :ok
    else
      render json: { error: "Invalid email address or password." }, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    render json: { message: "Signed out successfully." }, status: :ok
  end
end
