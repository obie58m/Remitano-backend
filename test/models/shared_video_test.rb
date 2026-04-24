# frozen_string_literal: true

require "test_helper"

class SharedVideoTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
  end

  test "rejects non-youtube urls" do
    YoutubeMetadata.stub(:fetch_title, nil) do
      video = SharedVideo.new(user: @user, youtube_url: "https://example.com")
      assert_not video.valid?
      assert_includes video.errors[:youtube_url], "is not a valid YouTube link"
    end
  end

  test "accepts valid youtube watch url with stubbed title" do
    YoutubeMetadata.stub(:fetch_title, "Nice clip") do
      video = SharedVideo.create!(
        user: @user,
        youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      )
      assert_equal "Nice clip", video.title
    end
  end
end
