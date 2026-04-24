# frozen_string_literal: true

class RootController < ApplicationController
  def show
    render json: {
      service: "youtube-video-sharing-api",
      version: "v1",
      health: "/up",
      cable: "/cable",
      api: "/api/v1"
    }
  end
end
