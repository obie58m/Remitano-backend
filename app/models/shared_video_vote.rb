class SharedVideoVote < ApplicationRecord
  belongs_to :user
  belongs_to :shared_video

  validates :value, inclusion: { in: [ -1, 1 ] }
end
