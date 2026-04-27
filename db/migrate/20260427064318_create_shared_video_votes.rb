class CreateSharedVideoVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :shared_video_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shared_video, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_index :shared_video_votes, [ :user_id, :shared_video_id ], unique: true
  end
end
