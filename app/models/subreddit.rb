class Subreddit < ApplicationRecord
  before_save { self.name = name.downcase }
  has_many :posts, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :reddit_id, presence: true, uniqueness: true
end
