# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140914194413) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blog_images", force: true do |t|
    t.string   "excite_url"
    t.integer  "tumblr_id",   limit: 8
    t.text     "tumblr_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blog_images", ["excite_url"], name: "index_blog_images_on_excite_url", unique: true, using: :btree

  create_table "blog_posts", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "excite_id"
    t.datetime "posted_at"
    t.integer  "tumblr_id",         limit: 8
    t.text     "tumblr_info"
    t.text     "content_in_excite"
  end

  add_index "blog_posts", ["excite_id"], name: "index_blog_posts_on_excite_id", unique: true, using: :btree
  add_index "blog_posts", ["posted_at"], name: "index_blog_posts_on_posted_at", using: :btree

  create_table "post_and_images", force: true do |t|
    t.integer  "blog_post_id"
    t.integer  "blog_image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_and_images", ["blog_image_id"], name: "index_post_and_images_on_blog_image_id", using: :btree
  add_index "post_and_images", ["blog_post_id", "blog_image_id"], name: "index_post_and_images_on_blog_post_id_and_blog_image_id", unique: true, using: :btree
  add_index "post_and_images", ["blog_post_id"], name: "index_post_and_images_on_blog_post_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

end
