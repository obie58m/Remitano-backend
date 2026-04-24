# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      include Authenticatable
      before_action :authenticate_request!, only: [ :me ]

      def register
        user = User.new(user_params)
        if user.save
          render json: auth_payload(user), status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by("LOWER(email) = ?", login_email)
        if user&.authenticate(params.require(:password))
          render json: auth_payload(user), status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def me
        render json: { user: serialize_user(current_user) }
      end

      private

      def user_params
        params.permit(:email, :password, :password_confirmation, :name)
      end

      def login_email
        params.require(:email).to_s.downcase.strip
      end

      def auth_payload(user)
        {
          token: JsonWebToken.encode(user.id),
          user: serialize_user(user)
        }
      end

      def serialize_user(user)
        {
          id: user.id,
          email: user.email,
          name: user.name
        }
      end
    end
  end
end
