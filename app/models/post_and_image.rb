# ブログ記事とブログ画像がmany to manyの関係になっているんじゃないかと思ったが、実際はすべてone to manyだった。。。
class PostAndImage < ActiveRecord::Base
  belongs_to :blog_post
  belongs_to :blog_image
  validates :blog_post_id, presence: true
  validates :blog_image_id, presence: true, uniqueness: { scope: :blog_post_id }
end
