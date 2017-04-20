class AddDumpToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :dump, :json, default: {}, null: false
  end
end
