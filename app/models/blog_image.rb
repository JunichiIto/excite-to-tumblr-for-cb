class BlogImage < ActiveRecord::Base
  SLEEP_SEC = 0.5
  BLOG_NAME = Settings.tumblr.blog_name
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

  def self.post_all_images_to_tumblr(limit: 1)
    self.where(tumblr_id: nil).order(:excite_url).limit(limit).each do |blog_image|
      blog_image.post_to_tumblr
    end
  end

  def post_to_tumblr
    logger.info "[INFO] Posting #{id} / #{excite_url}"

    result = tumblr_client.create_post :photo, BLOG_NAME, source: excite_url, caption: photo_date
    self.tumblr_id = result['id']
    raise "Invalid result #{result.inspect}" if tumblr_id.blank?
    sleep SLEEP_SEC

    result = tumblr_client.posts BLOG_NAME, type: 'photo', id: tumblr_id
    self.tumblr_info = result
    raise "Invalid result #{result.inspect}" if tumblr_info.blank?
    sleep SLEEP_SEC

    self.save!
  end

  def photo_date
    date = excite_url.scan(/(\d{6})\/(\d{2})/).flatten.join.to_date
    "撮影日 #{I18n.l date}"
  end

  def tumblr_client
    @tumblr_cient ||= Tumblr::Client.new
  end
end
