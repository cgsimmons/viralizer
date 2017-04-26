# app/services/reddit_service.rb
require 'reddit/api'
# Service to connect to reddit api
class RedditService
  def initialize
    @subreddit = 'popular'
    sign_in
  end

  def update_params(params)
    @subreddit = params[:subreddit]
  end

  def sign_in
    fail = 1
    while fail > 0 && fail < 25
      begin
        @session = Reddit::Services::User.new ENV['REDDIT_USERNAME'],
                                              ENV['REDDIT_PASSWORD'],
                                              ENV['REDDIT_ID'],
                                              ENV['REDDIT_SECRET'],
                                              ENV['REDDIT_USER_AGENT'],
                                              request_throttle: false
        fail = 0
      rescue RestClient::ExceptionWithResponse => err
        puts "Reddit API Authentication Error: #{err}"
        fail += 1
      end
    end
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
                                               max_size: 1000,
                                               remove_sticky: false
    rescue RestClient::ExceptionWithResponse => err
      puts "Reddit API Request Error: #{err}"
    end
    l
  end
end
