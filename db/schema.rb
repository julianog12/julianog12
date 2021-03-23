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

ActiveRecord::Schema.define(version: 2021_03_23_201650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "componentes", force: :cascade do |t|
    t.string "nome"
    t.text "linha"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cd_empresa", limit: 3
    t.string "tipo", limit: 32
  end

  create_table "configuracaos", force: :cascade do |t|
    t.string "cd_empresa", limit: 2
    t.string "parametro", limit: 50
    t.string "valor", limit: 400
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "diffs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "funcaos", force: :cascade do |t|
    t.string "nm_funcao", limit: 100
    t.string "cd_componente"
    t.string "tipo", limit: 20
    t.text "codigo"
    t.string "cd_empresa", limit: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "documentacao"
    t.string "nm_campo", limit: 32
    t.string "nm_tabela", limit: 32
    t.string "nm_modelo", limit: 20
    t.integer "nr_linhas"
    t.index ["cd_componente", "nm_funcao", "nm_campo", "nm_tabela", "cd_empresa"], name: "index_funcao_01", unique: true
    t.index ["cd_empresa", "nm_modelo"], name: "index_funcao_02"
  end

  create_table "series", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
