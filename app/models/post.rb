class Post < ApplicationRecord
  belongs_to :subreddit, autosave: true

  validates :reddit_id, uniqueness: true
end
