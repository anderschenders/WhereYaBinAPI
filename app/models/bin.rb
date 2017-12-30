class Bin < ApplicationRecord
  has_many :user_bins
  has_many :users, :through => :user_bins
  
  validates :bin_type, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
end
