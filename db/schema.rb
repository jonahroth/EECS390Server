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

ActiveRecord::Schema.define(version: 20150924031902) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lobby", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "time_added"
  end

  create_table "packages", force: :cascade do |t|
    t.string  "name"
    t.integer "price"
    t.text    "description"
  end

  create_table "powerups", force: :cascade do |t|
    t.string "name"
    t.string "path"
    t.string "identifier"
    t.text   "description"
  end

  create_table "purchasables", force: :cascade do |t|
    t.string  "name"
    t.integer "price"
    t.text    "description"
    t.string  "type"
  end

  create_table "user_packages", force: :cascade do |t|
    t.datetime "date_purchased"
    t.text     "wallpapers",     default: [], array: true
    t.text     "powerups",       default: [], array: true
  end

  create_table "user_purchases", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "purchasable_id"
    t.datetime "purchase_date"
    t.string   "type"
  end

  create_table "users", force: :cascade do |t|
    t.string  "username"
    t.integer "level"
    t.string  "salt"
    t.string  "password_hash"
    t.string  "location"
    t.date    "date_created"
    t.date    "last_signed_in"
    t.integer "peanuts"
    t.integer "rank"
  end

  create_table "wallpapers", force: :cascade do |t|
    t.string "name"
    t.string "path"
    t.string "identifier"
    t.text   "description"
  end

end
