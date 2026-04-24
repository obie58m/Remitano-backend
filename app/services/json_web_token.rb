# frozen_string_literal: true

class JsonWebToken
  ALGORITHM = "HS256"
  EXPIRATION = 24.hours

  class << self
    def encode(user_id)
      payload = {
        "sub" => user_id,
        "exp" => EXPIRATION.from_now.to_i
      }
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      return if token.blank?

      decoded = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })
      decoded.first
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    private

    def secret_key
      ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
    end
  end
end
