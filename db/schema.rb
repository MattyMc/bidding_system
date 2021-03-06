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

ActiveRecord::Schema.define(version: 20140719192550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auctions", force: true do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.decimal  "current_price",  precision: 10, scale: 2
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "best_bidder_id"
  end

  create_table "items", force: true do |t|
    t.string   "name"
    t.decimal  "start_price", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "users", force: true do |t|
    t.decimal  "budget",         precision: 10, scale: 2
    t.decimal  "blocked_budget", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "owned_item_ids"
  end

end
