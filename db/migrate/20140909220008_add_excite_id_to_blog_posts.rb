class AddExciteIdToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :excite_id, :integer
    add_index :blog_posts, :excite_id, unique: true
  end
end
