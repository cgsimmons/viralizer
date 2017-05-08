# Job to process subreddit query through reddit API
class RedditQueryJob < ApplicationJob
  queue_as :default

  def perform(subreddit)
    sub = Subreddit.find_by(name: subreddit)
    return unless sub.nil? || sub.updated_at < 1.day.ago
    reddit_client = RedditService.new
    reddit_client.update_params(
      subreddit: subreddit
    )
    posts = reddit_client.listings
    return if posts.nil?
    save_posts(posts)
  end

  def save_posts(posts)
    sub = save_sub(posts.first)
    posts.each do |post|
      save_post(post, sub)
    end
  end

  def save_sub(post)
    sub_params = sub_params_from_post(post)
    sub = Subreddit.find_by(name: sub_params[:name])
    sub.touch unless sub.nil?
    sub = Subreddit.new(sub_params) if sub.nil?
    sub
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

  def save_post(post, sub)
    post_params = post_params_from_post(post)
    new_post = Post.new(post_params)
    new_post.subreddit = sub
    new_post.save
  end
end
