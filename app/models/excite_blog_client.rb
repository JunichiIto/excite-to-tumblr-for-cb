require 'open-uri'
require 'nokogiri'
class ExciteBlogClient
  BASE_URL = 'http://lapin418.exblog.jp/'
  START_ID = '11934923'
  END_ID   = '20041527'

  def read_post(excite_id)
    url = "http://lapin418.exblog.jp/#{excite_id}/"

    logger.info "[INFO] Reading #{url}"

    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    node = doc.xpath('//div[@id="post"]').first

    title = node.xpath('//h2[@class="subj"]').text
    post_date_text = node.xpath('//div[@class="postdate"]').text
    content_html = node.xpath('//p').first.inner_html
    old_page_url = doc.xpath('//a[@class="older_page"]').first['href']

    post_date = post_date_text.scan(/(\d+)年 (\d+)月 (\d+)日/).join('-').to_date
    old_page_id = old_page_url[/\d{8}/]

    [BlogPost.new(title: title, post_date: post_date, excite_id: excite_id, content: content_html), old_page_id]
  end

  def logger
    Rails.logger
  end
end