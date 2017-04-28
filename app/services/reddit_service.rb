# app/services/reddit_service.rb
# require 'reddit/api'
require 'redd'
# Service to connect to reddit api
class RedditService
  def initialize
    @subreddit = ''
    sign_in
  end

  def update_params(params)
    @subreddit = params[:subreddit]
  end

  def sign_in
    fail = 1
    while fail > 0 && fail < 3
      begin
        @session = Redd.it(
          username: ENV['REDDIT_USERNAME'],
          password: ENV['REDDIT_PASSWORD'],
          client_id: ENV['REDDIT_ID'],
          secret: ENV['REDDIT_SECRET'],
          user_agent: ENV['REDDIT_USER_AGENT']
        )
        fail = 0
      rescue HTTP::TimeoutError => err
        puts "Reddit API Authentication Error: #{err}"
        fail += 1
      rescue JSON::ParserError => err
        puts "Reddit API Sign-in Error: #{err}"
        fail += 1
      end
    end
  end

  def signed_in?
    !@session.nil?
  end

  def listings
    return nil unless signed_in?
    l = @session.subreddit(@subreddit)
    begin
      hot = l.hot if l
    rescue JSON::ParserError => err
      puts "Subreddit not found #{err}"
      return []
    end
    hot.to_ary if hot
  end
end
