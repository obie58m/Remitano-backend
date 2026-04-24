# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires email name and password on create" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
    assert_includes user.errors[:name], "can't be blank"
  end

  test "normalizes email" do
    user = User.new(
      email: "  Hello@EXAMPLE.com ",
      name: "Sam",
      password: "password123",
      password_confirmation: "password123"
    )
    user.valid?
    assert_equal "hello@example.com", user.email
  end

  test "rejects short password" do
    user = User.new(
      email: "new@example.com",
      name: "Sam",
      password: "short",
      password_confirmation: "short"
    )
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end
end
