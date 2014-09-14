class CreateBlogImages < ActiveRecord::Migration
  def change
    create_table :blog_images do |t|
      t.string :excite_url
      t.integer :tumblr_id
      t.text :tumblr_info

      t.timestamps
    end
    add_index :blog_images, :excite_url, unique: true
    add_index :blog_images, :tumblr_id, unique: true
  end
end
