require 'distance'

class User < ApplicationRecord
  include Distance

  has_many :user_bins
  has_many :bins, :through => :user_bins

  validates :uid, presence: true

  # add uniqueness?
  validates :username, presence: true

  # add uniqueness and format?
  #validates :email, presence: true

  #validates :password, presence: true
  # validates_length_of :password, :minimum => 1

  # validates :bin_count, presence: true

  before_save :default_values

  def total_distance_travelled

    # get all action="use" bins
    if self.user_bins.length == 0
      return 0
    else

      action_use = self.user_bins.select { |user_bin| user_bin.action == "use"}

      total_distance = 0
        action_use.each do |user_bin|
        user_lat = user_bin.user_lat
        user_lng = user_bin.user_lng

        bin_id = user_bin.bin_id
        bin = Bin.find_by(id: bin_id)
        bin_lat = bin.latitude
        bin_lng = bin.longitude

        current_distance = distance_between_two_points(user_lat, user_lng, bin_lat, bin_lng)
        total_distance += current_distance
      end

      return total_distance.round(2)
    end
  end

  def default_values
    self.bin_count ||= 0
  end
end
