class Bin < ApplicationRecord
  validates :bin_type, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
end
