class AddIndexToSubredditsName < ActiveRecord::Migration[5.0]
  def change
    add_index :subreddits, :name, unique: true
  end
end
