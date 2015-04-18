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

ActiveRecord::Schema.define(version: 2) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "torrent_files", force: :cascade do |t|
    t.integer "torrent_id"
    t.string  "path",       array: true
    t.integer "length"
    t.string  "md5sum"
  end

  add_index "torrent_files", ["torrent_id"], name: "index_torrent_files_on_torrent_id", using: :btree

  create_table "torrents", force: :cascade do |t|
    t.string   "announce"
    t.string   "announce_list", array: true
    t.datetime "creation_date"
    t.string   "comment"
    t.string   "created_by"
    t.string   "encoding"
    t.text     "pieces"
    t.integer  "piece_length"
    t.integer  "private"
    t.string   "name"
  end

  add_foreign_key "torrent_files", "torrents"
end
