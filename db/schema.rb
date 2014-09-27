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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140925043303) do

  create_table "nfc_tags", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "tag_id",                          :null => false
    t.integer  "lifetime_balance", :default => 0, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "nfc_tags", ["tag_id"], :name => "index_nfc_tags_on_tag_id", :unique => true
  add_index "nfc_tags", ["user_id"], :name => "index_nfc_tags_on_user_id"

  create_table "nicknames", :force => true do |t|
    t.integer  "column",     :null => false
    t.string   "word",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "opportunities", :force => true do |t|
    t.string   "name"
    t.string   "email",      :null => false
    t.string   "location"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "payloads", :force => true do |t|
    t.integer  "nfc_tag_id",                :null => false
    t.string   "uri"
    t.text     "content"
    t.integer  "threshold",  :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "payloads", ["nfc_tag_id", "threshold"], :name => "index_payloads_on_nfc_tag_id_and_threshold", :unique => true
  add_index "payloads", ["nfc_tag_id"], :name => "index_payloads_on_nfc_tag_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "transaction_details", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "subject_id",                                       :null => false
    t.integer  "target_id",                                        :null => false
    t.integer  "credit_satoshi"
    t.integer  "debit_satoshi"
    t.decimal  "conversion_rate",                                  :null => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "currency",        :limit => 16, :default => "USD", :null => false
  end

  add_index "transaction_details", ["subject_id"], :name => "index_transaction_details_on_subject_id"
  add_index "transaction_details", ["target_id"], :name => "index_transaction_details_on_target_id"

  create_table "transactions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "nfc_tag_id"
    t.integer  "payload_id"
    t.integer  "dest_id"
    t.integer  "satoshi_amount"
    t.integer  "dollar_amount"
    t.string   "comment"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "transactions", ["nfc_tag_id"], :name => "index_transactions_on_nfc_tag_id"
  add_index "transactions", ["payload_id"], :name => "index_transactions_on_payload_id"
  add_index "transactions", ["user_id"], :name => "index_transactions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => "", :null => false
    t.string   "name",                                 :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "phone_secret_key",       :limit => 16,                 :null => false
    t.string   "inbound_btc_address"
    t.string   "outbound_btc_address"
    t.integer  "satoshi_balance",                      :default => 0,  :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["phone_secret_key"], :name => "index_users_on_phone_secret_key", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
