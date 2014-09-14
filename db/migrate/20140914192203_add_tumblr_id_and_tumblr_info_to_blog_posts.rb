class AddTumblrIdAndTumblrInfoToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :tumblr_id, :integer, limit: 8
    add_column :blog_posts, :tumblr_info, :text
  end
end
