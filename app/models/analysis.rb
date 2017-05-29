
# Tableless model for search form validations
class Analysis
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :min_upvotes, :subreddit,
                :time_zone, :reddit_client

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

  def successful_search?
    return true unless sub_needs_update?
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

  # Acceptable stale data up to 5 days old is served.
  # Refresh in background job if between 1 and 5 days old.
  def save_posts(posts)
    sub = save_sub(posts.first)
    posts.each do |post|
      save_post(post, sub)
    end
  end

  private

  def sub_needs_update?
    sub_record = Subreddit.find_by(name: @subreddit)
    return true if sub_record.nil? || sub_record.updated_at < 5.days.ago
    RedditQueryJob.perform_later(@subreddit) if sub_record.updated_at < 1.day.ago
    false
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
    if sub.nil?
      sub = Subreddit.new(sub_params)
    else
      sub.touch # updated_at should be updated
    end
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
