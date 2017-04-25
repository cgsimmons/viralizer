class AddCommentsToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :num_comments, :Integer
  end
end
