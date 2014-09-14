class AddContentInExciteToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :content_in_excite, :text
  end
end
