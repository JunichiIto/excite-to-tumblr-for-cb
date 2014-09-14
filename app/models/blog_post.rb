class BlogPost < ActiveRecord::Base
  acts_as_taggable

  def self.import_all_posts(latest_id: nil, oldest_id: nil, dry_run: true)
    self.transaction do
      self.destroy_all
      blog_posts = ExciteBlogClient.new.read_all(latest_id: latest_id, oldest_id: oldest_id)
      blog_posts.each(&:save!)
      raise ActiveRecord::Rollback if dry_run
    end
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
end
