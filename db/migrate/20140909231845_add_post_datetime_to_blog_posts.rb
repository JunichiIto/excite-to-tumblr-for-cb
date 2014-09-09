class AddPostDatetimeToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :posted_at, :datetime
    add_index :blog_posts, :posted_at
  end
end
