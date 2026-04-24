# frozen_string_literal: true

require "test_helper"

class JsonWebTokenTest < ActiveSupport::TestCase
  test "encode and decode round trip" do
    token = JsonWebToken.encode(42)
    payload = JsonWebToken.decode(token)
    assert_equal 42, payload["sub"]
  end

  test "decode returns nil for garbage" do
    assert_nil JsonWebToken.decode("not-a-jwt")
  end
end
