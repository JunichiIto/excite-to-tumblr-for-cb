class ChangeTypeOfTumblrId < ActiveRecord::Migration
  def change
    change_column :blog_images, :tumblr_id, :integer, limit: 8
  end
end
