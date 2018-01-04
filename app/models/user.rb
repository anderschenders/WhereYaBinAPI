class User < ApplicationRecord
  has_many :user_bins
  has_many :bins, :through => :user_bins

  # add uniqueness?
  validates :username, presence: true

  # add uniqueness and format?
  validates :email, presence: true

  validates :password, presence: true
  # validates_length_of :password, :minimum => 1

  before_save :default_values

  def default_values
    self.bin_count ||= 0
  end

end
