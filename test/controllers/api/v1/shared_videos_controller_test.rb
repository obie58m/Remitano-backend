# frozen_string_literal: true

require "test_helper"

class Api::V1::SharedVideosControllerTest < ActionDispatch::IntegrationTest
  test "index requires auth" do
    get api_v1_shared_videos_url, as: :json
    assert_response :unauthorized
  end

  test "index returns list with token" do
    token = JsonWebToken.encode(users(:alice).id)
    get api_v1_shared_videos_url,
        headers: { Authorization: "Bearer #{token}" },
        as: :json
    assert_response :ok
    list = JSON.parse(response.body)
    assert list.is_a?(Array)
  end

  test "index respects limit cap" do
    now = Time.current
    bid = users(:bob).id
    SharedVideo.insert_all!(
      [
        { user_id: bid, youtube_url: "https://www.youtube.com/watch?v=jNQXAC9IVRw", title: "A", created_at: now, updated_at: now },
        { user_id: bid, youtube_url: "https://www.youtube.com/watch?v=9bZkp7q19f0", title: "B", created_at: now, updated_at: now },
        { user_id: bid, youtube_url: "https://youtu.be/dQw4w9WgXcQ", title: "C", created_at: now, updated_at: now }
      ]
    )

    token = JsonWebToken.encode(users(:alice).id)
    get api_v1_shared_videos_url,
        params: { limit: 2 },
        headers: { Authorization: "Bearer #{token}", "Accept" => "application/json" }
    assert_response :ok
    assert_equal 2, JSON.parse(response.body).size
  end

  test "create requires auth" do
    YoutubeMetadata.stub(:fetch_title, "T") do
      post api_v1_shared_videos_url,
           params: { youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" },
           as: :json
    end
    assert_response :unauthorized
  end

  test "create succeeds with token" do
    token = JsonWebToken.encode(users(:alice).id)
    YoutubeMetadata.stub(:fetch_title, "T") do
      assert_enqueued_jobs 1, only: BroadcastNewVideoJob do
        post api_v1_shared_videos_url,
             headers: { Authorization: "Bearer #{token}" },
             params: { youtube_url: "https://www.youtube.com/watch?v=jNQXAC9IVRw" },
             as: :json
      end
    end
    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "T", body["title"]
  end
end
