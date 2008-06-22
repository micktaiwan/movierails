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

ActiveRecord::Schema.define(:version => 20080615180709) do

  create_table "movies", :force => true do |t|
    t.string   "title",      :null => false
    t.string   "year"
    t.string   "director"
    t.datetime "created_at"
  end

  create_table "movies_users", :id => false, :force => true do |t|
    t.integer  "movie_id",   :limit => 11
    t.integer  "user_id",    :limit => 11
    t.datetime "created_at"
    t.text     "descr"
    t.integer  "note",       :limit => 11
  end

  create_table "urls", :force => true do |t|
    t.integer  "movie_id",   :limit => 11
    t.string   "url"
    t.datetime "created_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                    :null => false
    t.string   "password",   :limit => 40, :null => false
    t.string   "lost_key"
    t.datetime "last_login"
    t.datetime "created_at"
  end

end
