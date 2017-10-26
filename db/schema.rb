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

ActiveRecord::Schema.define(version: 20171026090314) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "consignees", force: :cascade do |t|
    t.integer "location_id"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "containers", force: :cascade do |t|
    t.integer "shipment_id"
    t.string "size_class"
    t.string "weight_class"
    t.decimal "payload_in_kg"
    t.decimal "tare_weight"
    t.decimal "gross_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string "url"
    t.integer "shipment_id"
    t.string "text"
    t.string "doc_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lcl_cargos", force: :cascade do |t|
    t.integer "shipment_id"
    t.decimal "payload_in_kg"
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.decimal "dimension_z"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "location_type"
    t.string "hub_name"
    t.string "hub_operator"
    t.string "hub_address_details"
    t.string "hub_status"
    t.float "latitude"
    t.float "longitude"
    t.string "geocoded_address"
    t.string "street"
    t.string "street_number"
    t.string "zip_code"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifyees", force: :cascade do |t|
    t.integer "location_id"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ocean_pricings", force: :cascade do |t|
    t.string "starthub_name"
    t.string "endhub_name"
    t.string "size"
    t.string "weight_class"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pricings", force: :cascade do |t|
    t.integer "customer_id"
    t.string "origin_id"
    t.string "destination_id"
    t.string "currency"
    t.decimal "air_m3_ton_price"
    t.decimal "lcl_m3_ton_price"
    t.decimal "fcl_20f_price"
    t.decimal "fcl_40f_price"
    t.decimal "fcl_40f_hq_price"
    t.datetime "exp_date"
    t.string "mode_of_transport"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "route_locations", force: :cascade do |t|
    t.integer "route_id"
    t.integer "location_id"
    t.integer "position_in_hub_chain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routes", force: :cascade do |t|
    t.integer "starthub_id"
    t.integer "endhub_id"
    t.string "name"
    t.string "trade_direction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_charges", force: :cascade do |t|
    t.string "trade_direction"
    t.string "container_size_class"
    t.decimal "handling_documentation"
    t.decimal "equipment_management_charges"
    t.decimal "carrier_security_fee"
    t.decimal "verified_gross_mass"
    t.decimal "hazardous_cargo"
    t.decimal "add_imo_position"
    t.decimal "export_pickup_charge"
    t.decimal "import_drop_off_charge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipment_notifyees", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "notifyee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipments", force: :cascade do |t|
    t.integer "shipper_id"
    t.integer "consignee_id"
    t.integer "tenant_id"
    t.string "load_type"
    t.string "hs_code"
    t.string "cargo_notes"
    t.string "total_goods_value"
    t.datetime "planned_pickup_date"
    t.integer "origin_id"
    t.integer "destination_id"
    t.integer "route_id"
    t.boolean "has_pre_carriage"
    t.boolean "has_on_carriage"
    t.decimal "pre_carriage_distance_km"
    t.decimal "on_carriage_distance_km"
    t.string "haulage"
    t.decimal "total_price"
    t.string "status"
    t.string "imc_reference"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["load_type"], name: "index_shipments_on_load_type"
  end

  create_table "train_pricings", force: :cascade do |t|
    t.string "starthub_name"
    t.string "endhub_name"
    t.string "size"
    t.string "weight_class"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "train_schedules", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.datetime "etd"
    t.datetime "eta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_pricings", force: :cascade do |t|
    t.integer "trucker_id"
    t.decimal "price_fix"
    t.decimal "price_per_km"
    t.decimal "price_per_ton"
    t.decimal "price_per_m3"
    t.float "fcl_limit_m3_40_foot", default: 70.0
    t.float "fcl_limit_tons_40_foot", default: 24.0
    t.decimal "fcl_price", default: "3095.0"
    t.decimal "steptable_min_price", default: "217.0"
    t.jsonb "steptable"
    t.string "currency", default: "USD"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_route_discounts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "route_id"
    t.decimal "discount_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "location_id"
    t.string "email"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.text "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "vessel_schedules", force: :cascade do |t|
    t.string "vessel"
    t.string "voyage_code"
    t.string "from"
    t.string "to"
    t.datetime "ets"
    t.datetime "eta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
