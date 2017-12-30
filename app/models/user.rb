class User < ApplicationRecord
  # add uniqueness?
  validates :username, presence: true

  # add uniqueness and format?
  validates :email, presence: true

  validates :password, presence: true
end
