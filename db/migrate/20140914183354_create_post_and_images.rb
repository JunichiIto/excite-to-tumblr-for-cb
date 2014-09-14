class CreatePostAndImages < ActiveRecord::Migration
  def change
    create_table :post_and_images do |t|
      t.references :blog_post, index: true
      t.references :blog_image, index: true

      t.timestamps
    end
    add_index :post_and_images, [:blog_post_id, :blog_image_id], unique: true
  end
end
