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

ActiveRecord::Schema.define(version: 20131212193846) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: true do |t|
    t.datetime "time"
    t.integer  "duration"
    t.string   "place"
    t.boolean  "expert_confirmed",   default: false
    t.integer  "expert_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
    t.text     "description"
    t.boolean  "online"
    t.boolean  "user_confirmed"
    t.integer  "request_id"
    t.string   "appt_state",         default: "new"
    t.string   "hangout_url"
    t.boolean  "is_hangout_active"
    t.boolean  "is_reviewed",        default: false
    t.datetime "hangout_start_time"
    t.integer  "transaction_id"
    t.string   "time_zone"
    t.decimal  "hourly_rate"
    t.integer  "message_id"
  end

  create_table "availabilities", force: true do |t|
    t.integer  "expert_id"
    t.text     "timespans"
    t.float    "hourly_cost"
    t.integer  "timezone_in_minutes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone"
  end

  add_index "availabilities", ["expert_id"], name: "index_availabilities_on_expert_id", using: :btree

  create_table "available_tags", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", force: true do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "credit_transactions", force: true do |t|
    t.integer  "amount"
    t.boolean  "added"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transacter_id"
    t.integer  "transacted_id"
    t.text     "description"
    t.string   "transaction_id"
    t.string   "transaction_status"
    t.boolean  "is_request_cancel"
    t.boolean  "is_request_hold"
    t.text     "request_cancel_reason"
    t.string   "transaction_escrow_status"
  end

  create_table "expertises", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "expert_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expertises", ["expert_id"], name: "index_expertises_on_expert_id", using: :btree

  create_table "interests", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "interests", ["user_id"], name: "index_interests_on_user_id", using: :btree

  create_table "invites", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "approved",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  create_table "notifications", force: true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "notifications", ["conversation_id"], name: "index_notifications_on_conversation_id", using: :btree

  create_table "problems", force: true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "problems_requests", id: false, force: true do |t|
    t.integer "request_id"
    t.integer "problem_id"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "receipts", force: true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "receipts", ["notification_id"], name: "index_receipts_on_notification_id", using: :btree

  create_table "requests", force: true do |t|
    t.integer  "requester_id"
    t.integer  "requested_id"
    t.string   "company_name"
    t.string   "company_url"
    t.integer  "appt_length"
    t.boolean  "is_local"
    t.boolean  "is_online"
    t.string   "request_state",       default: "new"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "company_description"
    t.text     "problem_description"
    t.string   "local_zip"
    t.string   "problem_headline"
  end

  create_table "reviews", force: true do |t|
    t.integer  "reviewer_id"
    t.integer  "reviewed_id"
    t.float    "rating"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "appointment_id"
  end

  create_table "settings", force: true do |t|
    t.string "name"
    t.string "value"
  end

  add_index "settings", ["name"], name: "index_settings_on_name", using: :btree

  create_table "sidekiqjobs", force: true do |t|
    t.string   "sidekiq_id"
    t.integer  "workable_id"
    t.string   "workable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sidekiqjobs", ["workable_id", "workable_type"], name: "index_sidekiqjobs_on_workable_id_and_workable_type", using: :btree

  create_table "social_media", force: true do |t|
    t.string   "name"
    t.string   "profile"
    t.text     "data"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "social_media", ["user_id"], name: "index_social_media_on_user_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  create_table "users", force: true do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "tag_line"
    t.text     "bio"
    t.string   "location"
    t.string   "website"
    t.string   "image"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "zip_code"
    t.text     "job"
    t.boolean  "admin",                             default: false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "step_1_complete",                   default: false
    t.boolean  "step_2_complete",                   default: false
    t.boolean  "expert_approved",                   default: false
    t.string   "braintree_id"
    t.string   "braintree_last4"
    t.boolean  "is_expert_applied"
    t.string   "braintree_token"
    t.string   "braintree_merchant_id"
    t.string   "braintree_merchant_status"
    t.text     "braintree_merchant_status_message"
    t.boolean  "is_featured",                       default: false
    t.text     "about_description"
    t.string   "github_url"
    t.string   "stack_overflow_url"
    t.string   "linked_in_url"
    t.string   "personal_website"
    t.integer  "failed_attempts",                   default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "delete_record"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "notifications", "conversations", name: "notifications_on_conversation_id"

  add_foreign_key "receipts", "notifications", name: "receipts_on_notification_id"

end
