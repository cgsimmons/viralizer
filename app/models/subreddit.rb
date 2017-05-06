class Subreddit < ApplicationRecord
  before_save { self.name = name.downcase }
  has_many :posts, dependent: :destroy

  VALID_SUBREDDIT_REGEX = /\A[A-Za-z0-9][A-Za-z0-9_]{2,20}\Z/i

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: VALID_SUBREDDIT_REGEX
  validates :reddit_id, presence: true, uniqueness: true
end
# subreddit_rx = re.compile(r"\A[A-Za-z0-9][A-Za-z0-9_]{2,20}\Z")
