# Tableless model for search form validations
class Analysis
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :min_upvotes, :subreddit, :time_zone, :reddit_client

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
    @reddit_client = RedditService.new
  end

  def persisted?
    false
  end

  def search
    posts = listings
    if posts.nil?
      errors.add(:subreddit, 'Must be a valid subreddit.')
      return nil
    end
    posts.each do |post|
      save_post(post)
    end
  end

  def analyze
    Groupdate.time_zone = @time_zone
    sub = Subreddit.where('lower(name) = ?', @subreddit.downcase).first
    sub.posts.where('ups > ?', @min_upvotes.to_i)
    # posts = sub.posts.where('ups > ?', @min_upvotes.to_i)
    # posts_analysis = {}
    # posts_analysis['by_hour'] = posts_by_hour_hash(posts)
    # posts_analysis['count'] = posts.count
    # posts_analysis
  end

  private

  def posts_by_hour_hash(posts)
    # Hash.new([0, 0, 0]).tap do |h|
    Hash.new(0).tap do |h|
      posts.each do |post|
        next if post.nil?
        h[post.post_date.hour] += 1
        # tmp = h[post.post_date.hour]
        # tmp[0] += 1
        # tmp[1] += post.ups
      end
    end
  end

  def save_post(post)
    sub_params = sub_params_from_post(post)
    post_params = post_params_from_post(post)
    sub = Subreddit.find_by(reddit_id: sub_params[:reddit_id])
    sub = Subreddit.new(sub_params) if sub.nil?
    new_post = Post.new(post_params)
    new_post.subreddit = sub
    new_post.save
  end

  def listings
    @reddit_client.update_params(
      subreddit: @subreddit
    )
    @reddit_client.listings
  end

  def post_params_from_post(post)
    { dump: post,
      ups: post['data']['ups'],
      reddit_id: post['data']['name'],
      post_date_ts: post['data']['created_utc'] }
  end

  def sub_params_from_post(post)
    { name: post['data']['subreddit'],
      reddit_id: post['data']['subreddit_id'] }
  end
end
