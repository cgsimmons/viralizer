class Post < ApplicationRecord
  belongs_to :subreddit

  validates :reddit_id, uniqueness: true
end
