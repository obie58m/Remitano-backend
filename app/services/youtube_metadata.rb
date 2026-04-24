# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

class YoutubeMetadata
  OEMBED_URL = "https://www.youtube.com/oembed"

  class << self
    def video_id_from_url(raw_url)
      return if raw_url.blank?

      uri = URI.parse(raw_url.strip)
      host = uri.host&.downcase
      return unless host&.include?("youtube") || host == "youtu.be"

      if host == "youtu.be"
        id = uri.path.delete_prefix("/").split(/[?&#]/).first
        return id if id.present? && id.match?(/\A[a-zA-Z0-9_-]{6,}\z/)
      end

      if uri.path&.include?("/embed/")
        id = uri.path.split("/embed/").last&.split(/[?&#]/).first
        return id if id.present?
      end

      params = URI.decode_www_form(uri.query || "").to_h
      params["v"].presence
    rescue URI::InvalidURIError
      nil
    end

    def fetch_title(url)
      uri = URI(OEMBED_URL)
      uri.query = URI.encode_www_form(url: url, format: "json")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5
      res = http.get(uri.request_uri)
      return nil unless res.is_a?(Net::HTTPSuccess)

      data = JSON.parse(res.body)
      data["title"]
    rescue StandardError
      nil
    end
  end
end
