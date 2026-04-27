# frozen_string_literal: true

# Include this concern and add in the controller:
#   before_action :authenticate_request!, only: [ :create, ... ]
module Authenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_request!
    set_current_user_from_bearer_token
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def try_authenticate_request!
    set_current_user_from_bearer_token
  end

  def bearer_token
    header = request.headers["Authorization"]
    return if header.blank?

    header.split.last
  end

  def current_user
    @current_user
  end

  def set_current_user_from_bearer_token
    token = bearer_token
    payload = JsonWebToken.decode(token)
    @current_user = User.find_by(id: payload&.dig("sub")) if payload
  end
end
