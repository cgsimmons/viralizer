class Subreddit < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :name, uniqueness: true
  validates :reddit_id, uniqueness: true
end
