class PostAndImage < ActiveRecord::Base
  belongs_to :blog_post
  belongs_to :blog_image
  validates :blog_post_id, presence: true
  validates :blog_image_id, presence: true, uniqueness: { scope: :blog_post_id }
end
