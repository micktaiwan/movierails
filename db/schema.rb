# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091128140222) do

  create_table "movies", :force => true do |t|
    t.string   "title",      :null => false
    t.string   "year"
    t.string   "director"
    t.datetime "created_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "opinions", :force => true do |t|
    t.integer  "movie_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.date     "saw_on"
    t.text     "comment"
    t.integer  "rating"
  end

  create_table "urls", :force => true do |t|
    t.integer  "movie_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.string   "name"
    t.string   "url"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                                         :null => false
    t.string   "password",     :limit => 40,                    :null => false
    t.string   "lost_key"
    t.datetime "last_login"
    t.datetime "created_at"
    t.boolean  "want_mail",                  :default => true
    t.boolean  "include_mine",               :default => false
  end

end
