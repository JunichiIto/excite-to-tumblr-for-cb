class BlogImage < ActiveRecord::Base
  SLEEP_SEC = 0.5
  BLOG_NAME = Settings.tumblr.blog_name
  has_many :post_and_images
  has_many :blog_posts, through: :post_and_images
  validates :excite_url, presence: true, uniqueness: true
  validates :tumblr_id, uniqueness: true, allow_blank: true
  serialize :tumblr_info

  # 旧ブログの本文に含まれる画像URLからレコードを作成する
  def self.create_blog_images
    BlogPost.all.each do |blog_post|
      blog_post.image_urls.each do |url|
        # 本当ならここでpost_and_imagesも作るべき
        blog_image = find_or_create_by(excite_url: url)
        raise blog_image.errors.inspect unless blog_image.persisted?
      end
    end
  end

  # create_blog_imagesでpost_and_imagesを作らなかったので、このメソッドで後付けする
  def self.link_all_posts_and_images
    BlogPost.transaction do
      BlogPost.all.each do |blog_post|
        blog_post.image_urls.each do |url|
          blog_image = self.find_by_excite_url!(url)
          blog_image.blog_posts << blog_post
        end
      end
    end
  end

  # 登録されている画像をTumblrに投稿する
  # limit = nilであれば全件に対して実行する。
  # ただし、Tumblr APIの仕様上、1日の最大投稿件数は150件まで
  def self.post_all_images_to_tumblr(limit: 1)
    self.where(tumblr_id: nil).order(:excite_url).limit(limit).each do |blog_image|
      blog_image.post_to_tumblr
    end
  end

  # 最初のバージョンではTumblr投稿時の情報がおかしかったので、このメソッドで修正する
  # 現在のバージョンではこのメソッドを呼び出す必要はない
  def self.fix_all_tumblr_photo_info(limit: 1)
    self.where.not(tumblr_id: nil).limit(limit).each do |blog_image|
      blog_image.fix_tumblr_photo_info
    end
  end

  def tumblr_url
    raise "tumblr_info is blank." if tumblr_info.blank?
    tumblr_info['posts'][0]['photos'][0]['original_size']['url'].tap do |url|
      # たぶんありえないはず
      raise "Tumblr URL is blank!" if url.blank?
    end
  end

  def post_to_tumblr
    logger.info "[INFO] Posting #{id} / #{excite_url}"

    result = tumblr_client.create_post :photo, BLOG_NAME, source: excite_url, caption: caption_for_tumblr, date: photo_date_for_tumblr_param
    self.tumblr_id = result['id']
    raise "Invalid result #{result.inspect}" if tumblr_id.blank?
    sleep SLEEP_SEC

    result = tumblr_client.posts BLOG_NAME, type: 'photo', id: tumblr_id
    self.tumblr_info = result
    raise "Invalid result #{result.inspect}" if tumblr_info.blank?
    sleep SLEEP_SEC

    self.save!
  end

  def fix_tumblr_photo_info
    logger.info "[INFO] Fixing #{id} / #{tumblr_id}"

    result = tumblr_client.edit BLOG_NAME, id: tumblr_id, caption: caption_for_tumblr, date: photo_date_for_tumblr_param
    self.tumblr_id = result['id']
    raise "Invalid result #{result.inspect}" if tumblr_id.blank?
    sleep SLEEP_SEC

    result = tumblr_client.posts BLOG_NAME, type: 'photo', id: tumblr_id
    self.tumblr_info = result
    raise "Invalid result #{result.inspect}" if tumblr_info.blank?
    sleep SLEEP_SEC

    self.save!
  end

  private

  def first_blog_post
    self.blog_posts.order(:posted_at).first
  end

  def caption_for_tumblr
    "#{first_blog_post.title} (#{I18n.l photo_date})"
  end

  def photo_date_for_tumblr_param
    I18n.l photo_date, format: '%Y-%m-%d'
  end

  def photo_date
    excite_url.scan(/(\d{6})\/(\d{2})/).flatten.join.to_date
  end

  def tumblr_client
    @tumblr_client ||= Tumblr::Client.new
  end
end
