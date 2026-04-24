# frozen_string_literal: true

class BroadcastNewVideoJob < ApplicationJob
  queue_as :default

  def perform(shared_video_id)
    video = SharedVideo.includes(:user).find_by(id: shared_video_id)
    return unless video

    ActionCable.server.broadcast(
      "video_notifications",
      {
        type: "new_video",
        title: video.title,
        sharer_name: video.user.name,
        youtube_video_id: YoutubeMetadata.video_id_from_url(video.youtube_url)
      }
    )
  end
end
