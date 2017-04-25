# app/services/reddit_service.rb
require 'reddit/api'
# Service to connect to reddit api
class RedditService
  def initialize
    sign_in
  end

  def update_params(params)
    @subreddit = params[:subreddit]
    # @min_upvotes = params[:min_upvotes].to_i
  end

  def sign_in
    @session = Reddit::Services::User.new ENV['REDDIT_USERNAME'],
                                          ENV['REDDIT_PASSWORD'],
                                          ENV['REDDIT_ID'],
                                          ENV['REDDIT_SECRET'],
                                          ENV['REDDIT_USER_AGENT'],
                                          request_throttle: true
  rescue RestClient::ExceptionWithResponse => err
    puts "Reddit API Authentication Error: #{err}"
  end

  def signed_in?
    !@session.nil?
  end

  def listings
    return nil unless signed_in?
    begin
      l = Reddit::Services::Listings.batch_hot @session,
                                               basepath_subreddit: @subreddit,
                                               page_size: 100,
                                               max_size: 500
    rescue RestClient::ExceptionWithResponse => err
      puts "Reddit API Error: #{err}"
    end
    l
  end
end
