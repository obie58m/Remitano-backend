# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_04_27_070623) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "shared_video_votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shared_video_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shared_video_id"], name: "index_shared_video_votes_on_shared_video_id"
    t.index ["user_id", "shared_video_id"], name: "index_shared_video_votes_on_user_id_and_shared_video_id", unique: true
    t.index ["user_id"], name: "index_shared_video_votes_on_user_id"
  end

  create_table "shared_videos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "youtube_url", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0, null: false
    t.integer "downvotes_count", default: 0, null: false
    t.text "description"
    t.index ["user_id"], name: "index_shared_videos_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "shared_video_votes", "shared_videos"
  add_foreign_key "shared_video_votes", "users"
  add_foreign_key "shared_videos", "users"
end
