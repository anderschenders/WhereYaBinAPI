class UserBin < ApplicationRecord
  belongs_to :user
  belongs_to :bin

  validates :action, presence: true
end
