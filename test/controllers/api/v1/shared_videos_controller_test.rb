# frozen_string_literal: true

require "test_helper"

class Api::V1::SharedVideosControllerTest < ActionDispatch::IntegrationTest
  test "index requires auth" do
    get api_v1_shared_videos_url, as: :json
    assert_response :ok
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

  test "index includes vote counts and my_vote when authed" do
    token = JsonWebToken.encode(users(:alice).id)
    get api_v1_shared_videos_url,
        headers: { Authorization: "Bearer #{token}" },
        as: :json
    assert_response :ok
    item = JSON.parse(response.body).find { |v| v["id"] == shared_videos(:one).id }
    assert item
    assert_equal 0, item["downvotes_count"]
    assert_equal 1, item["upvotes_count"]
    assert_equal 1, item["my_vote"]
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
             params: { youtube_url: "https://www.youtube.com/watch?v=jNQXAC9IVRw", description: "Desc" },
             as: :json
      end
    end
    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "T", body["title"]
    assert_equal true, body["removable"]
    assert_equal "Desc", body["description"]
  end

  test "destroy requires auth" do
    delete api_v1_shared_video_url(shared_videos(:one)), as: :json
    assert_response :unauthorized
  end

  test "destroy removes own share and returns no content" do
    token = JsonWebToken.encode(users(:alice).id)
    assert_difference("SharedVideo.count", -1) do
      delete api_v1_shared_video_url(shared_videos(:one)),
             headers: { Authorization: "Bearer #{token}" },
             as: :json
    end
    assert_response :no_content
  end

  test "destroy returns not found for another users share" do
    token = JsonWebToken.encode(users(:bob).id)
    assert_no_difference("SharedVideo.count") do
      delete api_v1_shared_video_url(shared_videos(:one)),
             headers: { Authorization: "Bearer #{token}" },
             as: :json
    end
    assert_response :not_found
  end

  test "index entries mark removable for current user shares only" do
    token_alice = JsonWebToken.encode(users(:alice).id)
    get api_v1_shared_videos_url,
        headers: { Authorization: "Bearer #{token_alice}" },
        as: :json
    assert_response :ok
    list = JSON.parse(response.body)
    mine = list.find { |v| v["id"] == shared_videos(:one).id }
    assert mine
    assert_equal true, mine["removable"]

    token_bob = JsonWebToken.encode(users(:bob).id)
    get api_v1_shared_videos_url,
        headers: { Authorization: "Bearer #{token_bob}" },
        as: :json
    assert_response :ok
    other = JSON.parse(response.body).find { |v| v["id"] == shared_videos(:one).id }
    assert other
    assert_equal false, other["removable"]
  end

  test "vote requires auth" do
    post vote_api_v1_shared_video_url(shared_videos(:one)), params: { value: 1 }, as: :json
    assert_response :unauthorized
  end

  test "vote up then clear" do
    token = JsonWebToken.encode(users(:bob).id)
    post vote_api_v1_shared_video_url(shared_videos(:one)),
         headers: { Authorization: "Bearer #{token}" },
         params: { value: 1 },
         as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 2, body["upvotes_count"]
    assert_equal 0, body["downvotes_count"]
    assert_equal 1, body["my_vote"]

    post vote_api_v1_shared_video_url(shared_videos(:one)),
         headers: { Authorization: "Bearer #{token}" },
         params: { value: 0 },
         as: :json
    assert_response :ok
    body2 = JSON.parse(response.body)
    assert_equal 1, body2["upvotes_count"]
    assert_equal 0, body2["downvotes_count"]
    assert_equal 0, body2["my_vote"]
  end

  test "vote switches from up to down" do
    token = JsonWebToken.encode(users(:bob).id)
    post vote_api_v1_shared_video_url(shared_videos(:one)),
         headers: { Authorization: "Bearer #{token}" },
         params: { value: 1 },
         as: :json
    assert_response :ok

    post vote_api_v1_shared_video_url(shared_videos(:one)),
         headers: { Authorization: "Bearer #{token}" },
         params: { value: -1 },
         as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 1, body["upvotes_count"]
    assert_equal 1, body["downvotes_count"]
    assert_equal(-1, body["my_vote"])
  end
end
