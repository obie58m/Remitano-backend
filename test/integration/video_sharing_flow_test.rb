# frozen_string_literal: true

require "test_helper"

class VideoSharingFlowTest < ActionDispatch::IntegrationTest
  test "register login and list videos" do
    email = "flow-#{SecureRandom.hex(4)}@example.com"

    post api_v1_auth_register_url,
         params: {
           email: email,
           password: "password123",
           password_confirmation: "password123",
           name: "Flow User"
         },
         as: :json
    assert_response :created
    token = JSON.parse(response.body)["token"]

    get api_v1_shared_videos_url,
        headers: { Authorization: "Bearer #{token}" },
        as: :json
    assert_response :ok
  end

  test "share triggers background broadcast job" do
    token = JsonWebToken.encode(users(:bob).id)

    YoutubeMetadata.stub(:fetch_title, "Integration title") do
      assert_enqueued_with(job: BroadcastNewVideoJob) do
        post api_v1_shared_videos_url,
             headers: { Authorization: "Bearer #{token}" },
             params: { youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" },
             as: :json
      end
    end

    assert_response :created
  end
end
