# frozen_string_literal: true

require "test_helper"

class RootControllerTest < ActionDispatch::IntegrationTest
  test "root returns service metadata" do
    get "/"
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "youtube-video-sharing-api", body["service"]
    assert_equal "v1", body["version"]
    assert_equal "/up", body["health"]
  end
end
