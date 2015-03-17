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

ActiveRecord::Schema.define(version: 20150317172747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balances", force: true do |t|
    t.integer  "user_id"
    t.integer  "amount",          default: 0, null: false
    t.datetime "expiration_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "currency_id"
  end

  create_table "bitcoin_rates", force: true do |t|
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies", force: true do |t|
    t.integer  "user_id"
    t.string   "name",              limit: 24,               null: false
    t.string   "icon"
    t.integer  "expiration_days"
    t.integer  "status",                       default: 0,   null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "reserve_balance",              default: 0,   null: false
    t.boolean  "icon_processing"
    t.integer  "amount_per_dollar",            default: 100, null: false
    t.string   "symbol",            limit: 1
    t.integer  "max_amount",                   default: 500, null: false
    t.string   "slug"
  end

  add_index "currencies", ["name"], name: "index_currencies_on_name", unique: true, using: :btree
  add_index "currencies", ["slug"], name: "index_currencies_on_slug", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "denominations", force: true do |t|
    t.integer  "currency_id"
    t.integer  "value"
    t.string   "image"
    t.boolean  "image_processing"
    t.string   "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_logs", force: true do |t|
    t.string   "user",       limit: 16, null: false
    t.string   "os",         limit: 32, null: false
    t.string   "hardware",   limit: 48, null: false
    t.string   "message",               null: false
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_logs", ["hardware"], name: "index_device_logs_on_hardware", using: :btree
  add_index "device_logs", ["os"], name: "index_device_logs_on_os", using: :btree
  add_index "device_logs", ["user"], name: "index_device_logs_on_user", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "merchants", force: true do |t|
    t.integer  "user_id"
    t.decimal  "balance",               default: 0.0, null: false
    t.string   "name"
    t.string   "phone",      limit: 14
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state",      limit: 2
    t.string   "zip",        limit: 10
    t.string   "slug"
    t.text     "notes"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "nfc_tags", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "tag_id",                       null: false
    t.integer  "lifetime_balance", default: 0, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "currency_id"
  end

  add_index "nfc_tags", ["tag_id"], name: "index_nfc_tags_on_tag_id", unique: true, using: :btree
  add_index "nfc_tags", ["user_id"], name: "index_nfc_tags_on_user_id", using: :btree

  create_table "nicknames", force: true do |t|
    t.integer  "column",     null: false
    t.string   "word",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opportunities", force: true do |t|
    t.string   "name"
    t.string   "email",      null: false
    t.string   "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payloads", force: true do |t|
    t.integer  "nfc_tag_id",                                            null: false
    t.string   "uri"
    t.text     "content"
    t.integer  "threshold",                           default: 0,       null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "payload_image"
    t.string   "payload_thumb"
    t.string   "slug"
    t.string   "mobile_payload_image_url"
    t.string   "mobile_payload_thumb_url"
    t.string   "content_type",             limit: 16, default: "image", null: false
    t.boolean  "payload_image_processing"
    t.boolean  "payload_thumb_processing"
    t.string   "description"
  end

  add_index "payloads", ["nfc_tag_id", "threshold"], name: "index_payloads_on_nfc_tag_id_and_threshold", unique: true, using: :btree
  add_index "payloads", ["nfc_tag_id"], name: "index_payloads_on_nfc_tag_id", using: :btree
  add_index "payloads", ["slug"], name: "index_payloads_on_slug", unique: true, using: :btree

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "single_code_generators", force: true do |t|
    t.integer  "currency_id"
    t.string   "code",        limit: 32, null: false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "value",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "single_code_generators", ["code"], name: "index_single_code_generators_on_code", unique: true, using: :btree

  create_table "transaction_details", force: true do |t|
    t.integer  "transaction_id"
    t.integer  "subject_id",                                 null: false
    t.integer  "target_id",                                  null: false
    t.integer  "credit"
    t.integer  "debit"
    t.decimal  "conversion_rate",                            null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "currency",        limit: 16, default: "USD", null: false
  end

  add_index "transaction_details", ["subject_id"], name: "index_transaction_details_on_subject_id", using: :btree
  add_index "transaction_details", ["target_id"], name: "index_transaction_details_on_target_id", using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "user_id"
    t.integer  "nfc_tag_id"
    t.integer  "payload_id"
    t.integer  "dest_id"
    t.integer  "amount"
    t.integer  "dollar_amount"
    t.string   "comment"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "slug"
    t.integer  "voucher_id"
  end

  add_index "transactions", ["nfc_tag_id"], name: "index_transactions_on_nfc_tag_id", using: :btree
  add_index "transactions", ["payload_id"], name: "index_transactions_on_payload_id", using: :btree
  add_index "transactions", ["slug"], name: "index_transactions_on_slug", unique: true, using: :btree
  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                               default: "", null: false
    t.string   "encrypted_password",                  default: "", null: false
    t.string   "name",                                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "phone_secret_key",         limit: 16,              null: false
    t.string   "inbound_btc_address"
    t.string   "outbound_btc_address"
    t.integer  "satoshi_balance",                     default: 0,  null: false
    t.string   "profile_image"
    t.string   "profile_thumb"
    t.string   "mobile_profile_image_url"
    t.string   "mobile_profile_thumb_url"
    t.string   "inbound_btc_qrcode"
    t.integer  "role",                                default: 0,  null: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["phone_secret_key"], name: "index_users_on_phone_secret_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vouchers", force: true do |t|
    t.integer  "currency_id"
    t.integer  "user_id"
    t.string   "uid",             limit: 16,             null: false
    t.integer  "amount",                                 null: false
    t.integer  "status",                     default: 0, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.date     "expiration_date"
  end

  add_index "vouchers", ["uid"], name: "index_vouchers_on_uid", unique: true, using: :btree

end
