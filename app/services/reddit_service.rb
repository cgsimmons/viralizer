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
    sub = sub_link
    first_page = first_hot(sub)
    return [] if first_page.nil?
    hot_pages(first_page, sub)
  end

  def sub_link
    @session.subreddit(@subreddit)
  end

  def first_hot(sub)
    begin
      hot = sub.hot(limit: 100) if sub
    rescue JSON::ParserError => err
      puts "Subreddit not found #{err}"
      return nil
    end
    hot
  end

  def hot_pages(first_page, sub)
    array = first_page.to_ary
    next_page = first_page.after
    while next_page && array.length < 400
      tmp_page = sub.hot(after: next_page)
      array.push(*tmp_page.to_ary)
      next_page = tmp_page.after
    end
    array
  end
end
