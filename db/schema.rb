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

ActiveRecord::Schema.define(version: 20140414181852) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "enrollments", force: true do |t|
    t.integer  "work_group_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enrollments", ["student_id"], name: "index_enrollments_on_student_id", using: :btree
  add_index "enrollments", ["work_group_id"], name: "index_enrollments_on_work_group_id", using: :btree

  create_table "exercise_templates", force: true do |t|
    t.string   "text",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exercises", force: true do |t|
    t.integer  "template_id"
    t.integer  "work_group_id"
    t.integer  "sentence_length"
    t.string   "sentence_difficulty"
    t.string   "sentence_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exercises", ["template_id"], name: "index_exercises_on_template_id", using: :btree
  add_index "exercises", ["work_group_id"], name: "index_exercises_on_work_group_id", using: :btree

  create_table "sentences", force: true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "template_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["template_id"], name: "index_taggings_on_template_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "task_assignments", force: true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_assignments", ["task_id"], name: "index_task_assignments_on_task_id", using: :btree
  add_index "task_assignments", ["user_id"], name: "index_task_assignments_on_user_id", using: :btree

  create_table "tasks", force: true do |t|
    t.integer  "sentence_id",                  null: false
    t.integer  "exercise_id",                  null: false
    t.json     "teacher_solution"
    t.json     "student_solution"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state",            default: 0, null: false
  end

  create_table "users", force: true do |t|
    t.string   "login",                               null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "nick",                                null: false
    t.string   "first"
    t.string   "last"
    t.string   "role"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first"], name: "index_users_on_first", using: :btree
  add_index "users", ["last"], name: "index_users_on_last", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["nick"], name: "index_users_on_nick", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "work_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teacher_id", default: 0, null: false
  end

  add_index "work_groups", ["teacher_id"], name: "index_work_groups_on_teacher_id", using: :btree

end
