require 'open-uri'

class BlogPost < ActiveRecord::Base
  SLEEP_SEC = 0.5
  BLOG_NAME = Settings.tumblr.blog_name
  MIGRATION_MESSAGE = 'この記事はこちらに移動しました。'
  acts_as_taggable

  validates :tumblr_id, uniqueness: true, allow_blank: true
  serialize :tumblr_info

  def self.import_all_posts(latest_id: nil, oldest_id: nil, dry_run: true)
    self.transaction do
      self.destroy_all
      blog_posts = ExciteBlogClient.new.read_all(latest_id: latest_id, oldest_id: oldest_id)
      blog_posts.each(&:save!)
      raise ActiveRecord::Rollback if dry_run
    end
  end

  def self.post_all_posts_to_tumblr(limit: 1)
    excite_blog_writer = ExciteBlogWriter.new
    excite_blog_writer.login
    self.where(tumblr_id: nil).order(:posted_at).limit(limit).each do |blog_post|
      blog_post.post_to_tumblr(excite_blog_writer)
    end
  end

  def post_to_tumblr(excite_blog_writer)
    logger.info "[INFO] Posting #{id} / #{excite_url}"

    result = tumblr_client.create_post :text, BLOG_NAME, tags: tag_list, date: date_param_for_tumblr, title: title, body: content_for_tumblr
    self.tumblr_id = result['id']
    raise "Invalid result #{result.inspect}" if tumblr_id.blank?
    sleep SLEEP_SEC

    result = tumblr_client.posts BLOG_NAME, type: 'text', id: tumblr_id
    self.tumblr_info = result
    raise "Invalid result #{result.inspect}" if tumblr_info.blank?
    sleep SLEEP_SEC

    old_content = excite_blog_writer.edit_content(excite_id, replace_text)
    self.content_in_excite = old_content
    raise 'Old content is blank!' if self.content_in_excite.blank?

    assert_excite_is_updated

    self.save!
  end

  def assert_excite_is_updated
    html = html_in_excite_blog
    raise "Content is not updated! #{html}" unless html =~ /#{MIGRATION_MESSAGE}/
  end

  def html_in_excite_blog
    open(excite_url) do |f|
      f.read
    end
  end

  def replace_text
    <<-HTML
#{MIGRATION_MESSAGE}

<a href="#{tumblr_url}" target="_blank">#{tumblr_url}</a>
    HTML
  end

  def tumblr_url
    return '' if tumblr_info.blank?
    tumblr_info['posts'][0]['post_url']
  end

  def excite_url
    "http://lapin418.exblog.jp/#{excite_id}/"
  end

  def content_only
    content.gsub(/.*<!-- interest_match_relevant_zone_start -->|<!-- interest_match_relevant_zone_end -->.*/m, '')
  end

  def image_urls
    content.scan(/src="(http:\/\/pds.exblog.jp\/pds\/[^"]+)"/i).flatten
  end

  def content_for_tumblr_with_rescue
    content_for_tumblr
  rescue => e
    "ERROR: #{e.message}"
  end

  def content_for_tumblr
    return '' if content.blank?
    doc = content_as_nokogiri(content_without_unused_parts)
    doc = remove_comments(doc)
    doc = replace_image(doc)
    doc.css('body').inner_html
  end

  def remove_comments(doc)
    doc.xpath('//comment()').remove
    doc
  end

  def replace_image(doc)
    doc.css('a').each do |a|
      a.css('img').each do |img|
        src = img.attribute('src').value
        if src =~ /http:\/\/pds.exblog.jp\/pds\/\d/
          a.name = 'img'
          a.attributes.each{|k, v| a.remove_attribute(k)}
          a.set_attribute('src', new_image_url(src))
          a.inner_html = ''
        end
      end
    end
    doc
  end

  def content_without_unused_parts
    content.gsub(/(?:<br class="clear">)(?:<!-- interest_match_relevant_zone_end -->.*)?/m, '')
  end

  def new_image_url(old_url)
    BlogImage.find_by_excite_url(old_url).tumblr_url
  end

  def content_as_nokogiri(content_text)
    Nokogiri::HTML.parse(content_text)
  end

  def date_param_for_tumblr
    I18n.l posted_at, format: '%Y-%m-%d'
  end

  def tumblr_client
    @tumblr_client ||= Tumblr::Client.new
  end
end
