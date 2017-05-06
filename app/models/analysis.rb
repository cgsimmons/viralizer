
# Tableless model for search form validations
class Analysis
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :min_upvotes, :subreddit, :time_zone, :reddit_client

  VALID_SUBREDDIT_REGEX = /\A[A-Za-z0-9][A-Za-z0-9_]{2,20}\Z/i

  before_validation :downcase_subreddit
  validates :min_upvotes,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validates :subreddit, presence: true, format: VALID_SUBREDDIT_REGEX
  validate :valid_subreddit?

  INVALID_SUBS = %w(random all popular).freeze

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
    return true unless Subreddit.find_by(name: @subreddit).nil?
    posts = listings
    return false if posts.nil?
    if posts.empty?
      errors.add(:subreddit, 'Must be a valid subreddit.')
      return false
    end
    save_posts(posts)
    true
  end

  def analyze
    Groupdate.time_zone = @time_zone
    sub = Subreddit.find_by(name: @subreddit)
    sub.posts.where('ups > ?', @min_upvotes.to_i)
  end

  private

  def save_posts(posts)
    sub = save_sub(posts.first)
    posts.each do |post|
      save_post(post, sub)
    end
  end

  def save_post(post, sub)
    post_params = post_params_from_post(post)
    new_post = Post.new(post_params)
    new_post.subreddit = sub
    new_post.save
  end

  def save_sub(post)
    sub_params = sub_params_from_post(post)
    sub = Subreddit.find_by(name: @subreddit)
    sub = Subreddit.new(sub_params) if sub.nil?
    sub
  end

  def listings
    @reddit_client = RedditService.new
    @reddit_client.update_params(
      subreddit: @subreddit
    )
    @reddit_client.listings
  end

  def post_params_from_post(post)
    { ups: post.ups,
      reddit_id: post.name,
      num_comments: post.num_comments,
      post_date_ts: post.created_utc }
  end

  def sub_params_from_post(post)
    { name: post.subreddit.display_name,
      reddit_id: post.subreddit_id }
  end

  def valid_subreddit?
    return unless subreddit.present? && INVALID_SUBS.include?(subreddit)
    errors.add(:subreddit,
               "'popular', 'all', and 'random' are reserved by reddit.")
  end

  def downcase_subreddit
    self.subreddit = subreddit.downcase if subreddit.present?
  end
end
