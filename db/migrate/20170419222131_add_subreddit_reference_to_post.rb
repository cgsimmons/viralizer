class AddSubredditReferenceToPost < ActiveRecord::Migration[5.0]
  def change
    add_reference :posts, :subreddit, foreign_key: true
  end
end
