# frozen_string_literal: true

# Include this concern and add in the controller:
#   before_action :authenticate_request!, only: [ :create, ... ]
module Authenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_request!
    token = bearer_token
    payload = JsonWebToken.decode(token)
    @current_user = User.find_by(id: payload&.dig("sub")) if payload
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def bearer_token
    header = request.headers["Authorization"]
    return if header.blank?

    header.split.last
  end

  def current_user
    @current_user
  end
end
