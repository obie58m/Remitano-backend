# frozen_string_literal: true

module Api
  module V1
    class SharedVideosController < ApplicationController
      include Authenticatable
      before_action :try_authenticate_request!, only: %i[ index ]
      before_action :authenticate_request!, only: %i[ create destroy vote ]

      def index
        videos = SharedVideo.includes(:user).order(created_at: :desc).limit(index_limit)
        votes_by_video_id = {}
        if current_user
          votes_by_video_id = SharedVideoVote
            .where(user_id: current_user.id, shared_video_id: videos.map(&:id))
            .pluck(:shared_video_id, :value)
            .to_h
        end
        render json: videos.map { |v| serialize(v, my_vote: votes_by_video_id[v.id].to_i) }
      end

      def create
        video = current_user.shared_videos.build(shared_video_params)

        if video.save
          render json: serialize(video, my_vote: 0), status: :created
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

      # POST /api/v1/shared_videos/:id/vote
      # body: { value: 1 | -1 | 0 }  (0 clears vote)
      def vote
        video = SharedVideo.find(params[:id])
        value = params.require(:value).to_i
        unless [ -1, 0, 1 ].include?(value)
          return render json: { error: "Invalid vote value" }, status: :unprocessable_entity
        end

        existing = SharedVideoVote.find_by(user_id: current_user.id, shared_video_id: video.id)
        prev = existing&.value

        if value == 0
          existing&.destroy
          apply_vote_delta(video, prev, nil)
        else
          if existing
            existing.update!(value: value)
          else
            SharedVideoVote.create!(user_id: current_user.id, shared_video_id: video.id, value: value)
          end
          apply_vote_delta(video, prev, value)
        end

        video.reload
        my_vote = SharedVideoVote.find_by(user_id: current_user.id, shared_video_id: video.id)&.value.to_i
        render json: serialize(video, my_vote: my_vote), status: :ok
      end

      private

      def index_limit
        n = params[:limit].to_i
        n = 50 if n <= 0
        [ n, 100 ].min
      end

      def shared_video_params
        params.permit(:youtube_url, :title, :description)
      end

      def serialize(video, my_vote:)
        vid = YoutubeMetadata.video_id_from_url(video.youtube_url)
        {
          id: video.id,
          youtube_url: video.youtube_url,
          youtube_video_id: vid,
          title: video.title,
          description: video.description,
          sharer_name: video.user.name,
          sharer_email: video.user.email,
          created_at: video.created_at.iso8601,
          removable: current_user ? (video.user_id == current_user.id) : false,
          upvotes_count: video.upvotes_count,
          downvotes_count: video.downvotes_count,
          my_vote: my_vote
        }
      end

      def apply_vote_delta(video, prev, nextv)
        up = video.upvotes_count
        down = video.downvotes_count
        if prev == 1
          up -= 1
        elsif prev == -1
          down -= 1
        end
        if nextv == 1
          up += 1
        elsif nextv == -1
          down += 1
        end
        video.update!(upvotes_count: up, downvotes_count: down)
      end
    end
  end
end
