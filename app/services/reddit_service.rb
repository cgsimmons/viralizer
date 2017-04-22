# app/services/reddit_service.rb
require 'reddit/api'
# Service to connect to reddit api
class RedditService
  def initialize
    @session = sign_in
  end

  def update_params(params)
    @subreddit = params[:subreddit]
    @min_upvotes = params[:min_upvotes].to_i
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
    begin
      l = Reddit::Services::Listings.batch_hot @session,
                                               basepath_subreddit: @subreddit,
                                               page_size: 100,
                                               max_size: 500
    rescue RestClient::ExceptionWithResponse => err
      puts "Reddit API Error: #{err}"
      return nil
    end
    l.select { |post| post['data']['ups'].to_i > @min_upvotes }
  end
end
