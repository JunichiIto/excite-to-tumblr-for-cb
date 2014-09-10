require 'open-uri'
require 'nokogiri'
class ExciteBlogClient
  SLEEP_SEC = 0.5
  BASE_URL = 'http://lapin418.exblog.jp/'
  LATEST_ID = '20041527'
  OLDEST_ID = '11904220'

  def read_all(latest_id: LATEST_ID, oldest_id: OLDEST_ID)
    latest_id ||= LATEST_ID
    oldest_id ||= OLDEST_ID

    target_id = latest_id
    posts = []
    begin
      blog_post, target_id = read_post(target_id)
      posts << blog_post
    end while target_id.present? && target_id >= oldest_id
    posts
  end

  def read_post(excite_id)
    url = "http://lapin418.exblog.jp/#{excite_id}/"
    doc = read_doc_from_url(url)
    node = doc.xpath('//div[@id="post"]').first

    title = node.xpath('//h2[@class="subj"]').text
    content_html = read_content_html(doc)
    old_page_url = doc.xpath('//a[@class="older_page"]').first.try(:[], 'href')
    old_page_id = old_page_url[/\d{8}/] if old_page_url.present?

    tail_node = doc.xpath('//div[@class="posttail"]').first
    posted_at = tail_node.text[/\d+-\d+-\d+ \d+:\d+/]

    tag_nodes = tail_node.search('a').select do |node|
      node['href'] =~ /\/i\d+\//
    end
    tag_list = tag_nodes.map(&:text).join(',')

    [BlogPost.new(title: title, posted_at: posted_at, excite_id: excite_id, content: content_html, tag_list: tag_list), old_page_id]
  end

  def read_content_html(doc)
    start_comment = doc.at("//comment()[contains(.,'interest_match_relevant_zone_start')]")
    return start_comment.parent.inner_html if start_comment.parent.inner_html =~ /interest_match_relevant_zone_end/

    # タグ構造がおかしい場合に対処する
    content = Nokogiri::XML::NodeSet.new(doc)
    contained_node = start_comment.parent.next_sibling
    loop do
      break if contained_node.comment? && contained_node.text.strip == 'interest_match_relevant_zone_end'
      content << contained_node
      contained_node = contained_node.next_sibling
    end
    content.to_html
  end

  def read_doc_from_url(url)
    logger.info "[INFO] Reading #{url}"

    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    Nokogiri::HTML.parse(html, nil, charset).tap do
      sleep SLEEP_SEC
    end
  end

  def logger
    Rails.logger
  end
end