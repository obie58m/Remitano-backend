# frozen_string_literal: true

require "test_helper"

class YoutubeMetadataTest < ActiveSupport::TestCase
  test "parses watch url" do
    id = YoutubeMetadata.video_id_from_url("https://www.youtube.com/watch?v=abc123XY")
    assert_equal "abc123XY", id
  end

  test "parses youtu.be" do
    id = YoutubeMetadata.video_id_from_url("https://youtu.be/dQw4w9WgXcQ")
    assert_equal "dQw4w9WgXcQ", id
  end

  test "returns nil for unrelated host" do
    assert_nil YoutubeMetadata.video_id_from_url("https://vimeo.com/123")
  end
end
