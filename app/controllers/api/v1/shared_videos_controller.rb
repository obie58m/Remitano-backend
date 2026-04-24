# frozen_string_literal: true

module Api
  module V1
    class SharedVideosController < ApplicationController
      include Authenticatable
      before_action :authenticate_request!, only: %i[ index create destroy ]

      def index
        videos = SharedVideo.includes(:user).order(created_at: :desc).limit(index_limit)
        render json: videos.map { |v| serialize(v) }
      end

      def create
        video = current_user.shared_videos.build(shared_video_params)

        if video.save
          render json: serialize(video), status: :created
        else
          render json: { errors: video.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        video = current_user.shared_videos.find(params[:id])
        if video.destroy
          head :no_content
        else
          render json: { errors: video.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def index_limit
        n = params[:limit].to_i
        n = 50 if n <= 0
        [ n, 100 ].min
      end

      def shared_video_params
        params.permit(:youtube_url, :title)
      end

      def serialize(video)
        vid = YoutubeMetadata.video_id_from_url(video.youtube_url)
        {
          id: video.id,
          youtube_url: video.youtube_url,
          youtube_video_id: vid,
          title: video.title,
          sharer_name: video.user.name,
          created_at: video.created_at.iso8601,
          removable: video.user_id == current_user.id
        }
      end
    end
  end
end
