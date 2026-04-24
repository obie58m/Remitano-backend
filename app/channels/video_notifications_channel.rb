# frozen_string_literal: true

class VideoNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "video_notifications"
  end
end
