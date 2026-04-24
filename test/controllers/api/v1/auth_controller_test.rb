# frozen_string_literal: true

require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "register returns token" do
    assert_difference("User.count", 1) do
      post api_v1_auth_register_url,
           params: {
             email: "newperson@example.com",
             password: "password123",
             password_confirmation: "password123",
             name: "New Person"
           },
           as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert body["token"].present?
    assert_equal "New Person", body.dig("user", "name")
  end

  test "login returns token for fixture user" do
    post api_v1_auth_login_url,
         params: { email: users(:alice).email, password: "password1234" },
         as: :json

    assert_response :ok
    body = JSON.parse(response.body)
    assert body["token"].present?
    assert_equal "Alice", body.dig("user", "name")
  end

  test "login rejects bad password" do
    post api_v1_auth_login_url,
         params: { email: users(:alice).email, password: "wrongpassword" },
         as: :json

    assert_response :unauthorized
  end

  test "me requires auth" do
    get api_v1_auth_me_url, as: :json
    assert_response :unauthorized
  end

  test "me returns current user with valid token" do
    token = JsonWebToken.encode(users(:alice).id)
    get api_v1_auth_me_url,
        headers: { Authorization: "Bearer #{token}" },
        as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Alice", body.dig("user", "name")
    assert_equal users(:alice).email, body.dig("user", "email")
  end
end
