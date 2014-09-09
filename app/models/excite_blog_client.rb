require 'open-uri'
require 'nokogiri'
class ExciteBlogClient
  SLEEP_SEC = 0.5
  BASE_URL = 'http://lapin418.exblog.jp/'
  LATEST_ID   = '20041527'
  OLDEST_ID = '11904220'

  def read_all
    target_id = LATEST_ID
    posts = []
    begin
      blog_post, target_id = read_post(target_id)
      posts << blog_post
    end while target_id.present? && target_id >= OLDEST_ID
    posts
  end

  def read_post(excite_id)
    url = "http://lapin418.exblog.jp/#{excite_id}/"

    logger.info "[INFO] Reading #{url}"

    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    sleep SLEEP_SEC

    doc = Nokogiri::HTML.parse(html, nil, charset)
    node = doc.xpath('//div[@id="post"]').first

    title = node.xpath('//h2[@class="subj"]').text
    post_date_text = node.xpath('//div[@class="postdate"]').text
    content_html = node.xpath('//p').first.inner_html
    old_page_url = doc.xpath('//a[@class="older_page"]').first.try(:[], 'href')

    post_date = post_date_text.scan(/(\d+)年 (\d+)月 (\d+)日/).join('-').to_date
    old_page_id = old_page_url[/\d{8}/] if old_page_url.present?

    [BlogPost.new(title: title, post_date: post_date, excite_id: excite_id, content: content_html), old_page_id]
  end

  def logger
    Rails.logger
  end
end