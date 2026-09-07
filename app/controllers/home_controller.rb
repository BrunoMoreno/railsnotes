class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    render json: { message: "Welcome to the Notes API!" }
  end
end
