# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      token = request.params[:token].presence || extract_bearer_token
      payload = JsonWebToken.decode(token)
      user = User.find_by(id: payload&.dig("sub"))
      reject_unauthorized_connection unless user

      self.current_user = user
    end

    private

    def extract_bearer_token
      header = request.headers["Authorization"]
      return if header.blank?

      header.split.last
    end
  end
end
