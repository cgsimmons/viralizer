# Post model
class Post < ApplicationRecord
  attr_accessor :post_date_ts
  belongs_to :subreddit, autosave: true
  validates :reddit_id, uniqueness: true
  validates :num_comments,
            numericality: {
              only_integer: true,
              greater_than: -1
            }

  def post_date_ts=(ts)
    write_attribute :post_date, DateTime.strptime(ts.to_s, '%s')
  end
end
