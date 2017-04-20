# Controller for analysis subreddit search
class AnalysisController < ApplicationController
  def index
    @analysis ||= Analysis.new
  end

  def create
    @analysis = Analysis.new analysis_params
    if @analysis.valid?
      reddits = RedditService.new(
        subreddit: @analysis.subreddit,
        min_upvotes: @analysis.min_upvotes
      ).listings
      # byebug
      # puts reddits
      reddits.each do |post|
        data = post['data']
        subreddit_params = { name: data['subreddit'],
                             reddit_id: data['subreddit_id'] }
        post_params = { dump: post,
                        ups: data['ups'],
                        downs: data['downs'],
                        reddit_id: data['name'],
                        post_date: data['created_utc'] }
        sub = Subreddit.find_by(reddit_id: subreddit_params[:reddit_id])
        sub = Subreddit.new(subreddit_params) if sub.nil?
        # sub.save
        new_post = Post.new(post_params)
        new_post.subreddit = sub
        new_post.save
        # post_params['subreddit'] = s.id
        # post_test = sub.posts.create(post_params)
        # p.save
      end
    else
      flash.now[:alert] = 'Please complete the form below.'
    end
    render :index
  end

  private

  def analysis_params
    params.require(:analysis).permit([:min_upvotes, :subreddit])
  end
end
