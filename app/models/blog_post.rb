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
end
