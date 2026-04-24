# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class SharedVideosControllerTest < ActionDispatch::IntegrationTest
      test "index is public" do
        get api_v1_shared_videos_url, as: :json
        assert_response :ok
        list = JSON.parse(response.body)
        assert list.is_a?(Array)
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
  end
end
