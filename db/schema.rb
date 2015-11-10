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

ActiveRecord::Schema.define(version: 20151110022542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lobby", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "match_participants", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "match_id"
    t.boolean  "winner",     default: false
    t.integer  "score",      default: 0
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "match_datetime"
    t.string   "level",          default: "birch"
  end

  create_table "packages", force: :cascade do |t|
    t.string   "name"
    t.integer  "price"
    t.text     "description"
    t.integer  "min_wallpapers"
    t.integer  "max_wallpapers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "powerup_hash"
  end

  create_table "powerups", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.string   "identifier"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "used",        default: false
    t.string   "power_type",  default: "player", null: false
  end

  create_table "user_packages", force: :cascade do |t|
    t.text     "wallpapers", default: [], array: true
    t.text     "powerups",   default: [], array: true
    t.integer  "user_id"
    t.integer  "package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_powerups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_wallpaper_id"
    t.integer  "powerup_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "internal_order",    default: -1
  end

  create_table "user_wallpapers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "wallpaper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.integer  "level",          default: 1
    t.string   "salt"
    t.string   "password_hash"
    t.string   "location"
    t.integer  "peanuts"
    t.integer  "rank",           default: 10000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_signed_in"
    t.boolean  "facebook",       default: false
    t.string   "name"
  end

  create_table "wallpapers", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.string   "identifier"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "used",        default: false
  end

end
