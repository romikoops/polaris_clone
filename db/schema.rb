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

ActiveRecord::Schema.define(version: 20180416173637) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "aggregated_cargos", force: :cascade do |t|
    t.decimal "weight"
    t.decimal "volume"
    t.decimal "chargeable_weight"
    t.integer "shipment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cargo_item_types", force: :cascade do |t|
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.string "description"
    t.string "area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
  end

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
    t.integer "cargo_item_type_id"
    t.string "customs_text"
    t.decimal "chargeable_weight"
    t.boolean "stackable", default: true
    t.integer "quantity"
    t.jsonb "unit_price"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "user_id"
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
    t.string "customs_text"
    t.integer "quantity"
    t.jsonb "unit_price"
  end

  create_table "couriers", force: :cascade do |t|
    t.string "name"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "currencies", force: :cascade do |t|
    t.jsonb "today"
    t.jsonb "yesterday"
    t.string "base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customs_fees", force: :cascade do |t|
    t.jsonb "import"
    t.jsonb "export"
    t.string "mode_of_transport"
    t.string "load_type"
    t.integer "hub_id"
    t.integer "tenant_id"
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
    t.integer "tenant_id"
  end

  create_table "hub_truckings", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "trucking_destination_id"
    t.integer "trucking_pricing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "nexus_id"
  end

  create_table "itineraries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "mode_of_transport"
    t.integer "tenant_id"
    t.integer "mot_scope_id"
  end

  create_table "layovers", force: :cascade do |t|
    t.integer "stop_id"
    t.datetime "eta"
    t.datetime "etd"
    t.integer "stop_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "itinerary_id"
    t.integer "trip_id"
    t.datetime "closing_date"
  end

  create_table "local_charges", force: :cascade do |t|
    t.jsonb "import"
    t.jsonb "export"
    t.string "mode_of_transport"
    t.string "load_type"
    t.integer "hub_id"
    t.integer "tenant_id"
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
    t.string "premise"
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

  create_table "notes", force: :cascade do |t|
    t.integer "itinerary_id"
    t.integer "hub_id"
    t.integer "trucking_pricing_id"
    t.string "body"
    t.string "header"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "user_id"
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
    t.string "cargo_notes"
    t.string "haulage"
    t.string "hs_code", default: [], array: true
    t.jsonb "schedules_charges"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "schedule_set", default: [], array: true
    t.integer "tenant_id"
    t.datetime "planned_eta"
    t.datetime "planned_etd"
    t.integer "itinerary_id"
    t.jsonb "trucking"
    t.boolean "customs_credit", default: false
    t.jsonb "total_price"
    t.jsonb "total_goods_value"
    t.integer "trip_id"
    t.string "eori"
    t.string "direction"
    t.string "notes"
    t.jsonb "incoterm"
    t.integer "origin_hub_id"
    t.integer "destination_hub_id"
    t.datetime "booking_placed_at"
    t.jsonb "insurance"
    t.jsonb "customs"
    t.bigint "transport_category_id"
    t.index ["transport_category_id"], name: "index_shipments_on_transport_category_id"
  end

  create_table "stops", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "itinerary_id"
    t.integer "index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenant_cargo_item_types", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "cargo_item_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_item_type_id"], name: "index_tenant_cargo_item_types_on_cargo_item_type_id"
    t.index ["tenant_id"], name: "index_tenant_cargo_item_types_on_tenant_id"
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
    t.jsonb "web"
  end

  create_table "transport_categories", force: :cascade do |t|
    t.integer "vehicle_id"
    t.string "mode_of_transport"
    t.string "name"
    t.string "cargo_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "load_type"
  end

  create_table "trips", force: :cascade do |t|
    t.integer "itinerary_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "voyage_code"
    t.string "vessel"
    t.integer "tenant_vehicle_id"
  end

  create_table "trucking_destinations", force: :cascade do |t|
    t.string "zipcode"
    t.string "country_code"
    t.string "city_name"
    t.integer "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_name"], name: "index_trucking_destinations_on_city_name"
    t.index ["country_code"], name: "index_trucking_destinations_on_country_code"
    t.index ["distance"], name: "index_trucking_destinations_on_distance"
    t.index ["zipcode"], name: "index_trucking_destinations_on_zipcode"
  end

  create_table "trucking_pricings", force: :cascade do |t|
    t.integer "courier_id"
    t.string "load_type"
    t.jsonb "load_meterage"
    t.integer "cbm_ratio"
    t.string "modifier"
    t.integer "tenant_id"
    t.string "truck_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "carriage"
    t.jsonb "rates"
    t.jsonb "fees"
  end

  create_table "user_locations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.string "category"
    t.boolean "primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_managers", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "user_id"
    t.string "section"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "tenant_email", null: false
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
    t.string "vat_number"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
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

  add_foreign_key "shipments", "transport_categories"
  add_foreign_key "tenant_cargo_item_types", "cargo_item_types"
  add_foreign_key "tenant_cargo_item_types", "tenants"
  add_foreign_key "users", "roles"
end
