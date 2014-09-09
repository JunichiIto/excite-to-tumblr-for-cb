class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.date :post_date
      t.text :content

      t.timestamps
    end

    add_index :blog_posts, :post_date
  end
end
