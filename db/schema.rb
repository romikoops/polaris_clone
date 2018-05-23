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

ActiveRecord::Schema.define(version: 20180523081342) do

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

  create_table "conversations", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "tenant_id"
    t.integer "user_id"
    t.integer "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_updated"
    t.integer "unreads"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "geometries", force: :cascade do |t|
    t.string "name_1"
    t.string "name_2"
    t.string "name_3"
    t.string "name_4"
    t.geometry "data", limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_1", "name_2", "name_3", "name_4"], name: "index_geometries_on_name_1_and_name_2_and_name_3_and_name_4", unique: true
  end

  create_table "hub_truckings", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "trucking_destination_id"
    t.integer "trucking_pricing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trucking_pricing_id", "trucking_destination_id", "hub_id"], name: "foreign_keys", unique: true
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
    t.integer "mandatory_charge_id"
  end

  create_table "incoterm_charges", force: :cascade do |t|
    t.boolean "pre_carriage"
    t.boolean "on_carriage"
    t.boolean "freight", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "origin_warehousing"
    t.boolean "origin_labour"
    t.boolean "origin_packing"
    t.boolean "origin_loading"
    t.boolean "origin_customs"
    t.boolean "origin_port_charges"
    t.boolean "forwarders_fee"
    t.boolean "origin_vessel_loading"
    t.boolean "destination_port_charges"
    t.boolean "destination_customs"
    t.boolean "destination_loading"
    t.boolean "destination_labour"
    t.boolean "destination_warehousing"
  end

  create_table "incoterm_liabilities", force: :cascade do |t|
    t.boolean "pre_carriage"
    t.boolean "on_carriage"
    t.boolean "freight", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "origin_warehousing"
    t.boolean "origin_labour"
    t.boolean "origin_packing"
    t.boolean "origin_loading"
    t.boolean "origin_customs"
    t.boolean "origin_port_charges"
    t.boolean "forwarders_fee"
    t.boolean "origin_vessel_loading"
    t.boolean "destination_port_charges"
    t.boolean "destination_customs"
    t.boolean "destination_loading"
    t.boolean "destination_labour"
    t.boolean "destination_warehousing"
  end

  create_table "incoterm_scopes", force: :cascade do |t|
    t.boolean "pre_carriage"
    t.boolean "on_carriage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mode_of_transport"
  end

  create_table "incoterms", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "seller_incoterm_scope_id"
    t.integer "seller_incoterm_liability_id"
    t.integer "seller_incoterm_charge_id"
    t.integer "buyer_incoterm_scope_id"
    t.integer "buyer_incoterm_liability_id"
    t.integer "buyer_incoterm_charge_id"
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
    t.string "street_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province"
    t.string "photo"
    t.string "premise"
    t.integer "country_id"
  end

  create_table "mandatory_charges", force: :cascade do |t|
    t.boolean "pre_carriage"
    t.boolean "on_carriage"
    t.boolean "import_charges"
    t.boolean "export_charges"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "title"
    t.string "message"
    t.integer "conversation_id"
    t.boolean "read"
    t.datetime "read_at"
    t.integer "sender_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "pricing_details", force: :cascade do |t|
    t.decimal "rate"
    t.string "rate_basis"
    t.decimal "min"
    t.decimal "hw_threshold"
    t.string "hw_rate_basis"
    t.string "shipping_type"
    t.jsonb "range", default: []
    t.string "currency_name"
    t.bigint "currency_id"
    t.string "priceable_type"
    t.bigint "priceable_id"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_pricing_details_on_currency_id"
    t.index ["priceable_type", "priceable_id"], name: "index_pricing_details_on_priceable_type_and_priceable_id"
    t.index ["tenant_id"], name: "index_pricing_details_on_tenant_id"
  end

  create_table "pricing_exceptions", force: :cascade do |t|
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.bigint "pricing_id"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pricing_id"], name: "index_pricing_exceptions_on_pricing_id"
    t.index ["tenant_id"], name: "index_pricing_exceptions_on_tenant_id"
  end

  create_table "pricings", force: :cascade do |t|
    t.decimal "wm_rate"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.bigint "tenant_id"
    t.bigint "transport_category_id"
    t.bigint "user_id"
    t.bigint "itinerary_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itinerary_id"], name: "index_pricings_on_itinerary_id"
    t.index ["tenant_id"], name: "index_pricings_on_tenant_id"
    t.index ["transport_category_id"], name: "index_pricings_on_transport_category_id"
    t.index ["user_id"], name: "index_pricings_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
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
    t.integer "origin_hub_id"
    t.integer "destination_hub_id"
    t.datetime "booking_placed_at"
    t.jsonb "insurance"
    t.jsonb "customs"
    t.bigint "transport_category_id"
    t.integer "incoterm_id"
    t.integer "origin_nexus_id"
    t.integer "destination_nexus_id"
    t.datetime "closing_date"
    t.string "incoterm_text"
    t.datetime "planned_origin_drop_off_date"
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

  create_table "tenant_incoterms", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "incoterm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.jsonb "email_links"
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
    t.datetime "closing_date"
  end

  create_table "trucking_destinations", force: :cascade do |t|
    t.string "zipcode"
    t.string "country_code"
    t.string "city_name"
    t.integer "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "geometry_id"
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
    t.string "cargo_class"
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
    t.boolean "allow_password_change", default: false, null: false
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
