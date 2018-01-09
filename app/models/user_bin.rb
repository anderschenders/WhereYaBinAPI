class UserBin < ApplicationRecord
  belongs_to :user
  belongs_to :bin

  validates :action, presence: true
  validates :user_lat, presence: true
  validates :user_lng, presence: true
end
