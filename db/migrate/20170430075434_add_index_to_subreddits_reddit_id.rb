class AddIndexToSubredditsRedditId < ActiveRecord::Migration[5.0]
  def change
    add_index :subreddits, :reddit_id, unique: true
  end
end
