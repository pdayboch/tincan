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

ActiveRecord::Schema[7.2].define(version: 2024_09_10_000015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "bank_name"
    t.string "name", null: false
    t.string "account_type"
    t.boolean "active", default: true
    t.boolean "deletable", default: true
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "statement_directory"
    t.string "parser_class"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorization_conditions", force: :cascade do |t|
    t.bigint "categorization_rule_id", null: false
    t.string "transaction_field", null: false
    t.string "match_type", null: false
    t.string "match_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categorization_rule_id"], name: "index_categorization_conditions_on_categorization_rule_id"
  end

  create_table "categorization_rules", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "subcategory_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorization_rules_on_category_id"
    t.index ["subcategory_id"], name: "index_categorization_rules_on_subcategory_id"
  end

  create_table "statements", force: :cascade do |t|
    t.date "statement_date"
    t.bigint "account_id", null: false
    t.float "statement_balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "pdf_file_path"
    t.index ["account_id"], name: "index_statements_on_account_id"
  end

  create_table "subcategories", force: :cascade do |t|
    t.string "name"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_subcategories_on_category_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.date "transaction_date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.text "description"
    t.bigint "account_id", null: false
    t.bigint "statement_id"
    t.bigint "category_id", null: false
    t.bigint "subcategory_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.text "statement_description"
    t.date "statement_transaction_date"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["statement_id"], name: "index_transactions_on_statement_id"
    t.index ["subcategory_id"], name: "index_transactions_on_subcategory_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "categorization_conditions", "categorization_rules"
  add_foreign_key "categorization_rules", "categories"
  add_foreign_key "categorization_rules", "subcategories"
  add_foreign_key "statements", "accounts"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "statements"
  add_foreign_key "transactions", "subcategories"
end
