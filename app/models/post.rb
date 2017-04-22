# Post model
class Post < ApplicationRecord
  attr_accessor :post_date_ts
  belongs_to :subreddit, autosave: true
  validates :reddit_id, uniqueness: true

  def post_date_ts=(ts)
    write_attribute :post_date, DateTime.strptime(ts.to_s, '%s')
  end
end
