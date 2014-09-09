class RemovePostDateFrom < ActiveRecord::Migration
  def change
    remove_column :blog_posts, :post_date
  end
end
