class HomeController < ApplicationController
  def index
    render json: { message: "Welcome to the Notes API!" }
  end
end
