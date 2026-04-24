# frozen_string_literal: true

require "test_helper"

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    test "rejects connection without token" do
      assert_reject_connection { connect "/cable" }
    end

    test "connects with valid jwt param" do
      user = users(:alice)
      token = JsonWebToken.encode(user.id)

      connect "/cable", params: { token: token }

      assert_equal user.id, connection.current_user.id
    end
  end
end
