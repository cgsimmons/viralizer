# Job to process subreddit query through reddit API
class RedditQueryJob < ApplicationJob
  queue_as do
    if arguments.count > 1 && arguments[1] == 'high_priority'
      :high_priority
    else
      :warm_subreddit
    end
  end

  def perform(subreddit)
    sub = Subreddit.find_by(name: subreddit)
    return unless sub.nil? || sub.updated_at < 1.day.ago
    reddit_client = RedditService.new
    reddit_client.update_params(
      subreddit: subreddit
    )
    posts = reddit_client.listings
    return if posts.nil?
    analysis_object = Analysis.new(subreddit: subreddit, min_upvotes: 0)
    analysis_object.save_posts(posts)
  end
end
