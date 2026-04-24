# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

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
