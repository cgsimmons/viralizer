class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.datetime :post_date
      t.integer :ups
      t.string :reddit_id

      t.timestamps
    end
  end
end
