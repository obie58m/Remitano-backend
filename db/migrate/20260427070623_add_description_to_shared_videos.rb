class AddDescriptionToSharedVideos < ActiveRecord::Migration[7.2]
  def change
    add_column :shared_videos, :description, :text
  end
end
