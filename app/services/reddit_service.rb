# app/services/reddit_service.rb
require 'reddit/api'
# Service to connect to reddit api
class RedditService
  def initialize(params)
    @subreddit = params[:subreddit]
    @min_upvotes = params[:min_upvotes]
    @session = sign_in
  end

  def sign_in
    Reddit::Services::User.new ENV['REDDIT_USERNAME'],
                               ENV['REDDIT_PASSWORD'],
                               ENV['REDDIT_ID'],
                               ENV['REDDIT_SECRET'],
                               ENV['REDDIT_USER_AGENT'],
                               request_throttle: false
  end

  def listings
    Reddit::Services::Listings.batch_new @session,
                                         basepath_subreddit: @subreddit,
                                         page_size: 2,
                                         max_size: 5
  end
end
