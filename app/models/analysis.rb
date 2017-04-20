# Tableless model for search form validations
class Analysis
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :min_upvotes, :subreddit

  validates :min_upvotes,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validates :subreddit, presence: true

  class << self
    def all
      []
    end
  end

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end
  end

  def persisted?
    false
  end

  def search
    posts = RedditService.new(
      subreddit: @subreddit,
      min_upvotes: @min_upvotes
    ).listings
    # byebug
    # puts reddits
    posts.each do |post|
      data = post['data']
      subreddit_params = { name: data['subreddit'],
                           reddit_id: data['subreddit_id'] }
      post_params = { dump: post,
                      ups: data['ups'],
                      downs: data['downs'],
                      reddit_id: data['name'],
                      post_date_ts: data['created_utc'] }
      sub = Subreddit.find_by(reddit_id: subreddit_params[:reddit_id])
      sub = Subreddit.new(subreddit_params) if sub.nil?
      # sub.save
      new_post = Post.new(post_params)
      new_post.subreddit = sub
      new_post.save
    end
  end
end
