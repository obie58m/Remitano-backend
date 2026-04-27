# frozen_string_literal: true

class SharedVideo < ApplicationRecord
  belongs_to :user
  has_many :shared_video_votes, dependent: :destroy

  validates :youtube_url, presence: true, length: { maximum: 2048 }
  validates :description, length: { maximum: 5000 }, allow_nil: true

  before_validation :assign_metadata
  validate :youtube_url_format

  after_commit :enqueue_broadcast_notification, on: :create

  private

  def assign_metadata
    return if youtube_url.blank?

    fetched = YoutubeMetadata.fetch_title(youtube_url)
    self.title = fetched.presence || title.presence || fallback_title
  end

  def fallback_title
    YoutubeMetadata.video_id_from_url(youtube_url).present? ? "YouTube video" : "Untitled"
  end

  def youtube_url_format
    return if youtube_url.blank?

    errors.add(:youtube_url, "is not a valid YouTube link") if YoutubeMetadata.video_id_from_url(youtube_url).blank?
  end

  def enqueue_broadcast_notification
    BroadcastNewVideoJob.perform_later(id)
  end
end
