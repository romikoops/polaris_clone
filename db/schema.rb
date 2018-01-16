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

ActiveRecord::Schema.define(version: 20180116103428) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cargo_items", force: :cascade do |t|
    t.integer "shipment_id"
    t.decimal "payload_in_kg"
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.decimal "dimension_z"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dangerous_goods"
    t.string "cargo_class"
    t.string "hs_codes", default: [], array: true
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "shipper_id"
    t.integer "location_id"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alias", default: false
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
    t.boolean "dangerous_goods"
    t.string "cargo_class"
    t.string "hs_codes", default: [], array: true
  end

  create_table "currencies", force: :cascade do |t|
    t.jsonb "today"
    t.jsonb "yesterday"
    t.string "base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.integer "user_id"
    t.integer "shipment_id"
    t.string "doc_type"
    t.string "url"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "approved"
    t.jsonb "approval_details"
  end

  create_table "hub_routes", force: :cascade do |t|
    t.integer "starthub_id"
    t.integer "endhub_id"
    t.integer "route_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "hubs", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "location_id"
    t.string "name"
    t.string "hub_type"
    t.float "latitude"
    t.float "longitude"
    t.string "hub_status", default: "active"
    t.string "hub_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "trucking_type"
    t.string "photo"
  end

  create_table "itineraries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "location_type"
    t.float "latitude"
    t.float "longitude"
    t.string "geocoded_address"
    t.string "street"
    t.string "street_number"
    t.string "zip_code"
    t.string "city"
    t.string "country"
    t.string "street_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province"
    t.string "photo"
  end

  create_table "mot_scopes", force: :cascade do |t|
    t.boolean "ocean_container"
    t.boolean "ocean_cargo_item"
    t.boolean "air_container"
    t.boolean "air_cargo_item"
    t.boolean "rail_container"
    t.boolean "rail_cargo_item"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pricings", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "route_id"
    t.integer "customer_id"
    t.jsonb "air", default: {"wm_min"=>1, "wm_rate"=>nil, "currency"=>nil, "kg_per_cbm"=>167, "heavy_weight"=>nil, "heavy_wm_min"=>1}
    t.jsonb "lcl", default: {"wm_min"=>1, "wm_rate"=>nil, "currency"=>nil, "kg_per_cbm"=>1000, "heavy_weight"=>nil, "heavy_wm_min"=>1}
    t.jsonb "fcl_20f", default: {"rate"=>nil, "currency"=>nil, "kg_per_cbm"=>1000, "heavy_kg_min"=>nil, "heavy_weight"=>nil}
    t.jsonb "fcl_40f", default: {"rate"=>nil, "currency"=>nil, "kg_per_cbm"=>1000, "heavy_kg_min"=>nil, "heavy_weight"=>nil}
    t.jsonb "fcl_40f_hq", default: {"rate"=>nil, "currency"=>nil, "kg_per_cbm"=>1000, "heavy_kg_min"=>nil, "heavy_weight"=>nil}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dedicated"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routes", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "origin_nexus_id"
    t.integer "destination_nexus_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_fcl"
    t.boolean "has_lcl"
    t.bigint "mot_scope_id"
    t.index ["mot_scope_id"], name: "index_routes_on_mot_scope_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "route_id"
    t.string "mode_of_transport"
    t.datetime "etd"
    t.datetime "eta"
    t.string "vessel"
    t.string "call_sign"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hub_route_id"
    t.string "hub_route_key"
    t.integer "vehicle_id"
    t.integer "tenant_id"
  end

  create_table "service_charges", force: :cascade do |t|
    t.integer "hub_id"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.string "location"
    t.jsonb "terminal_handling_cbm"
    t.jsonb "terminal_handling_ton"
    t.jsonb "terminal_handling_min"
    t.jsonb "lcl_service_cbm"
    t.jsonb "lcl_service_ton"
    t.jsonb "lcl_service_min"
    t.jsonb "isps"
    t.jsonb "exp_declaration"
    t.jsonb "extra_hs_code"
    t.jsonb "doc_fee"
    t.jsonb "liner_service_fee"
    t.jsonb "vgm_fee"
    t.jsonb "security_fee"
    t.jsonb "documentation_fee"
    t.jsonb "handling_fee"
    t.jsonb "customs_clearance"
    t.jsonb "cfs_terminal_charges"
    t.jsonb "misc_fees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipment_contacts", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "contact_id"
    t.string "contact_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipments", force: :cascade do |t|
    t.integer "shipper_id"
    t.integer "shipper_location_id"
    t.integer "origin_id"
    t.integer "destination_id"
    t.integer "route_id"
    t.string "uuid"
    t.string "imc_reference"
    t.string "status"
    t.string "load_type"
    t.datetime "planned_pickup_date"
    t.boolean "has_pre_carriage"
    t.decimal "pre_carriage_distance_km"
    t.boolean "has_on_carriage"
    t.decimal "on_carriage_distance_km"
    t.decimal "total_price"
    t.decimal "total_goods_value"
    t.string "cargo_notes"
    t.string "haulage"
    t.string "hs_code", default: [], array: true
    t.jsonb "schedules_charges"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "schedule_set", default: [], array: true
    t.integer "tenant_id"
  end

  create_table "tenant_vehicles", force: :cascade do |t|
    t.integer "vehicle_id"
    t.integer "tenant_id"
    t.boolean "is_default"
    t.string "mode_of_transport"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "tenants", force: :cascade do |t|
    t.jsonb "theme"
    t.jsonb "emails"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "phones"
    t.jsonb "addresses"
    t.string "name"
    t.jsonb "scope"
    t.string "currency", default: "EUR"
  end

  create_table "transport_categories", force: :cascade do |t|
    t.integer "vehicle_id"
    t.string "mode_of_transport"
    t.string "name"
    t.string "cargo_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_pricings", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "nexus_id"
    t.integer "upper_zip"
    t.integer "lower_zip"
    t.jsonb "rate_table", default: [], array: true
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province"
    t.string "city"
    t.string "rate_type"
    t.string "dist_hub", default: [], array: true
  end

  create_table "user_locations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.string "category"
    t.boolean "primary", default: false
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
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.integer "tenant_id"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id"
    t.boolean "guest", default: false
    t.string "currency", default: "EUR"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "name"
    t.string "mode_of_transport"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "routes", "mot_scopes"
  add_foreign_key "users", "roles"
end
