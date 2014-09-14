class BlogImage < ActiveRecord::Base
  validates :excite_url, presence: true, uniqueness: true
  validates :tumblr_id, uniqueness: true, allow_blank: true
  serialize :tumblr_info

  def self.create_blog_images
    BlogPost.all.each do |blog_post|
      blog_post.image_urls.each do |url|
        blog_image = find_or_create_by(excite_url: url)
        raise blog_image.errors.inspect unless blog_image.persisted?
      end
    end
  end
end
