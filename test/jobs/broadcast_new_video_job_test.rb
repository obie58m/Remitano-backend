# frozen_string_literal: true

require "test_helper"

class BroadcastNewVideoJobTest < ActiveJob::TestCase
  test "broadcasts one message on stream" do
    video = shared_videos(:one)

    assert_broadcasts("video_notifications", 1) do
      BroadcastNewVideoJob.perform_now(video.id)
    end
  end
end
