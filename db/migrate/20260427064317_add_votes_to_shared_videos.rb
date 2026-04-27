class AddVotesToSharedVideos < ActiveRecord::Migration[7.2]
  def change
    add_column :shared_videos, :upvotes_count, :integer, null: false, default: 0
    add_column :shared_videos, :downvotes_count, :integer, null: false, default: 0
  end
end
