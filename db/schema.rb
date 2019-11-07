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

ActiveRecord::Schema.define(version: 2019_11_04_123443) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "tablefunc"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addons", force: :cascade do |t|
    t.string "accept_text"
    t.string "additional_info_text"
    t.string "addon_type"
    t.string "cargo_class"
    t.integer "counterpart_hub_id"
    t.datetime "created_at", null: false
    t.string "decline_text"
    t.string "direction"
    t.jsonb "fees"
    t.integer "hub_id"
    t.string "mode_of_transport"
    t.string "read_more"
    t.integer "tenant_id"
    t.integer "tenant_vehicle_id"
    t.jsonb "text", default: [], array: true
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_addons_on_tenant_id"
  end

  create_table "address_book_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city"
    t.string "company_name"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "geocoded_address"
    t.string "last_name"
    t.string "phone"
    t.geometry "point", limit: {:srid=>0, :type=>"geometry"}
    t.string "postal_code"
    t.string "premise"
    t.string "province"
    t.uuid "sandbox_id"
    t.string "street"
    t.string "street_number"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["sandbox_id"], name: "index_address_book_contacts_on_sandbox_id"
    t.index ["user_id"], name: "index_address_book_contacts_on_user_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "city"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.string "geocoded_address"
    t.float "latitude"
    t.string "location_type"
    t.float "longitude"
    t.string "name"
    t.string "photo"
    t.string "premise"
    t.string "province"
    t.uuid "sandbox_id"
    t.string "street"
    t.string "street_address"
    t.string "street_number"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["sandbox_id"], name: "index_addresses_on_sandbox_id"
  end

  create_table "agencies", force: :cascade do |t|
    t.integer "agency_manager_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_agencies_on_tenant_id"
  end

  create_table "aggregated_cargos", force: :cascade do |t|
    t.decimal "chargeable_weight"
    t.datetime "created_at", null: false
    t.uuid "sandbox_id"
    t.integer "shipment_id"
    t.datetime "updated_at", null: false
    t.decimal "volume"
    t.decimal "weight"
    t.index ["sandbox_id"], name: "index_aggregated_cargos_on_sandbox_id"
  end

  create_table "alternative_names", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "locale"
    t.string "model"
    t.string "model_id"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "cargo_cargos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "quotation_id"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["quotation_id"], name: "index_cargo_cargos_on_quotation_id"
    t.index ["tenant_id"], name: "index_cargo_cargos_on_tenant_id"
  end

  create_table "cargo_item_types", force: :cascade do |t|
    t.string "area"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "description"
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.datetime "updated_at", null: false
  end

  create_table "cargo_items", force: :cascade do |t|
    t.string "cargo_class"
    t.integer "cargo_item_type_id"
    t.decimal "chargeable_weight"
    t.datetime "created_at", null: false
    t.string "customs_text"
    t.boolean "dangerous_goods"
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.decimal "dimension_z"
    t.string "hs_codes", default: [], array: true
    t.decimal "payload_in_kg"
    t.integer "quantity"
    t.uuid "sandbox_id"
    t.integer "shipment_id"
    t.boolean "stackable", default: true
    t.jsonb "unit_price"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_cargo_items_on_sandbox_id"
  end

  create_table "cargo_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "cargo_class", default: 0
    t.uuid "cargo_id"
    t.bigint "cargo_type", default: 0
    t.datetime "created_at", null: false
    t.boolean "dangerous_goods", default: false
    t.string "height_unit", default: "m"
    t.decimal "height_value", precision: 100, scale: 4, default: "0.0"
    t.string "length_unit", default: "m"
    t.decimal "length_value", precision: 100, scale: 4, default: "0.0"
    t.integer "quantity", default: 0
    t.boolean "stackable", default: false
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.string "volume_unit", default: "m3"
    t.decimal "volume_value", precision: 100, scale: 6, default: "0.0"
    t.string "weight_unit", default: "kg"
    t.decimal "weight_value", precision: 100, scale: 3, default: "0.0"
    t.string "width_unit", default: "m"
    t.decimal "width_value", precision: 100, scale: 4, default: "0.0"
    t.index ["cargo_class"], name: "index_cargo_units_on_cargo_class"
    t.index ["cargo_id"], name: "index_cargo_units_on_cargo_id"
    t.index ["cargo_type"], name: "index_cargo_units_on_cargo_type"
    t.index ["tenant_id"], name: "index_cargo_units_on_tenant_id"
  end

  create_table "carriers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_carriers_on_sandbox_id"
  end

  create_table "charge_breakdowns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "sandbox_id"
    t.integer "shipment_id"
    t.integer "trip_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_charge_breakdowns_on_sandbox_id"
  end

  create_table "charge_categories", force: :cascade do |t|
    t.integer "cargo_unit_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_charge_categories_on_sandbox_id"
    t.index ["tenant_id"], name: "index_charge_categories_on_tenant_id"
  end

  create_table "charges", force: :cascade do |t|
    t.integer "charge_breakdown_id"
    t.integer "charge_category_id"
    t.integer "children_charge_category_id"
    t.datetime "created_at", null: false
    t.integer "detail_level"
    t.integer "edited_price_id"
    t.integer "parent_id"
    t.integer "price_id"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_charges_on_sandbox_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "address_id"
    t.boolean "alias", default: false
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "email", comment: "MASKED WITH EmailAddress"
    t.string "first_name", comment: "MASKED WITH FirstName"
    t.string "last_name", comment: "MASKED WITH LastName"
    t.string "phone", comment: "MASKED WITH Phone"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["sandbox_id"], name: "index_contacts_on_sandbox_id"
  end

  create_table "containers", force: :cascade do |t|
    t.string "cargo_class"
    t.datetime "created_at", null: false
    t.string "customs_text"
    t.boolean "dangerous_goods"
    t.decimal "gross_weight"
    t.string "hs_codes", default: [], array: true
    t.decimal "payload_in_kg"
    t.integer "quantity"
    t.uuid "sandbox_id"
    t.integer "shipment_id"
    t.string "size_class"
    t.decimal "tare_weight"
    t.jsonb "unit_price"
    t.datetime "updated_at", null: false
    t.string "weight_class"
    t.index ["sandbox_id"], name: "index_containers_on_sandbox_id"
  end

  create_table "contents", force: :cascade do |t|
    t.string "component"
    t.datetime "created_at", null: false
    t.integer "index"
    t.string "section"
    t.integer "tenant_id"
    t.jsonb "text", default: {}
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_contents_on_tenant_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_updated"
    t.integer "manager_id"
    t.integer "shipment_id"
    t.integer "tenant_id"
    t.integer "unreads"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["tenant_id"], name: "index_conversations_on_tenant_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "flag"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "couriers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_couriers_on_sandbox_id"
    t.index ["tenant_id"], name: "index_couriers_on_tenant_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "base"
    t.datetime "created_at", null: false
    t.integer "tenant_id"
    t.jsonb "today"
    t.datetime "updated_at", null: false
    t.jsonb "yesterday"
    t.index ["tenant_id"], name: "index_currencies_on_tenant_id"
  end

  create_table "customs_fees", force: :cascade do |t|
    t.integer "counterpart_hub_id"
    t.datetime "created_at", null: false
    t.string "direction"
    t.jsonb "fees"
    t.integer "hub_id"
    t.string "load_type"
    t.string "mode_of_transport"
    t.integer "tenant_id"
    t.integer "tenant_vehicle_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_customs_fees_on_tenant_id"
  end

  create_table "documents", force: :cascade do |t|
    t.jsonb "approval_details"
    t.string "approved"
    t.datetime "created_at", null: false
    t.string "doc_type"
    t.integer "quotation_id"
    t.uuid "sandbox_id"
    t.integer "shipment_id"
    t.integer "tenant_id"
    t.string "text"
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "user_id"
    t.index ["sandbox_id"], name: "index_documents_on_sandbox_id"
    t.index ["tenant_id"], name: "index_documents_on_tenant_id"
  end

  create_table "geometries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.geometry "data", limit: {:srid=>0, :type=>"geometry"}
    t.string "name_1"
    t.string "name_2"
    t.string "name_3"
    t.string "name_4"
    t.datetime "updated_at", null: false
    t.index ["name_1", "name_2", "name_3", "name_4"], name: "index_geometries_on_name_1_and_name_2_and_name_3_and_name_4", unique: true
  end

  create_table "hub_truck_type_availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "hub_id"
    t.integer "truck_type_availability_id"
    t.datetime "updated_at", null: false
  end

  create_table "hub_truckings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "hub_id"
    t.integer "trucking_destination_id"
    t.integer "trucking_pricing_id"
    t.datetime "updated_at", null: false
    t.index ["hub_id"], name: "index_hub_truckings_on_hub_id"
    t.index ["trucking_pricing_id", "trucking_destination_id", "hub_id"], name: "foreign_keys", unique: true
  end

  create_table "hubs", force: :cascade do |t|
    t.integer "address_id"
    t.datetime "created_at", null: false
    t.boolean "free_out", default: false
    t.string "hub_code"
    t.string "hub_status", default: "active"
    t.string "hub_type"
    t.float "latitude"
    t.float "longitude"
    t.integer "mandatory_charge_id"
    t.string "name"
    t.integer "nexus_id"
    t.string "photo"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.string "trucking_type"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_hubs_on_sandbox_id"
    t.index ["tenant_id"], name: "index_hubs_on_tenant_id"
  end

  create_table "incoterm_charges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "destination_customs"
    t.boolean "destination_labour"
    t.boolean "destination_loading"
    t.boolean "destination_port_charges"
    t.boolean "destination_warehousing"
    t.boolean "forwarders_fee"
    t.boolean "freight", default: true
    t.boolean "on_carriage"
    t.boolean "origin_customs"
    t.boolean "origin_labour"
    t.boolean "origin_loading"
    t.boolean "origin_packing"
    t.boolean "origin_port_charges"
    t.boolean "origin_vessel_loading"
    t.boolean "origin_warehousing"
    t.boolean "pre_carriage"
    t.datetime "updated_at", null: false
  end

  create_table "incoterm_liabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "destination_customs"
    t.boolean "destination_labour"
    t.boolean "destination_loading"
    t.boolean "destination_port_charges"
    t.boolean "destination_warehousing"
    t.boolean "forwarders_fee"
    t.boolean "freight", default: true
    t.boolean "on_carriage"
    t.boolean "origin_customs"
    t.boolean "origin_labour"
    t.boolean "origin_loading"
    t.boolean "origin_packing"
    t.boolean "origin_port_charges"
    t.boolean "origin_vessel_loading"
    t.boolean "origin_warehousing"
    t.boolean "pre_carriage"
    t.datetime "updated_at", null: false
  end

  create_table "incoterm_scopes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "mode_of_transport"
    t.boolean "on_carriage"
    t.boolean "pre_carriage"
    t.datetime "updated_at", null: false
  end

  create_table "incoterms", force: :cascade do |t|
    t.integer "buyer_incoterm_charge_id"
    t.integer "buyer_incoterm_liability_id"
    t.integer "buyer_incoterm_scope_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "seller_incoterm_charge_id"
    t.integer "seller_incoterm_liability_id"
    t.integer "seller_incoterm_scope_id"
    t.datetime "updated_at", null: false
  end

  create_table "itineraries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "mode_of_transport"
    t.string "name"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["mode_of_transport"], name: "index_itineraries_on_mode_of_transport"
    t.index ["name"], name: "index_itineraries_on_name"
    t.index ["sandbox_id"], name: "index_itineraries_on_sandbox_id"
    t.index ["tenant_id"], name: "index_itineraries_on_tenant_id"
  end

  create_table "layovers", force: :cascade do |t|
    t.datetime "closing_date"
    t.datetime "created_at", null: false
    t.datetime "eta"
    t.datetime "etd"
    t.integer "itinerary_id"
    t.uuid "sandbox_id"
    t.integer "stop_id"
    t.integer "stop_index"
    t.integer "trip_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_layovers_on_sandbox_id"
    t.index ["stop_id"], name: "index_layovers_on_stop_id"
  end

  create_table "legacy_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_aggregated_cargos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_cargo_item_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_cargo_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_charge_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_containers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_currencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_hubs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_itineraries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_layovers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_local_charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_shipments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_stops", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_tenant_vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_trips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "local_charges", force: :cascade do |t|
    t.integer "counterpart_hub_id"
    t.datetime "created_at", null: false
    t.boolean "dangerous", default: false
    t.string "direction"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.jsonb "fees"
    t.uuid "group_id"
    t.integer "hub_id"
    t.boolean "internal", default: false
    t.string "load_type"
    t.string "mode_of_transport"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.integer "tenant_vehicle_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["sandbox_id"], name: "index_local_charges_on_sandbox_id"
    t.index ["tenant_id"], name: "index_local_charges_on_tenant_id"
    t.index ["uuid"], name: "index_local_charges_on_uuid", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "admin_level"
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.string "city"
    t.string "country"
    t.string "neighbourhood"
    t.string "postal_code"
    t.string "province"
    t.string "suburb"
    t.index "to_tsvector('english'::regconfig, (city)::text)", name: "locations_to_tsvector_idx3", using: :gin
    t.index "to_tsvector('english'::regconfig, (country)::text)", name: "locations_to_tsvector_idx4", using: :gin
    t.index "to_tsvector('english'::regconfig, (neighbourhood)::text)", name: "locations_to_tsvector_idx2", using: :gin
    t.index "to_tsvector('english'::regconfig, (postal_code)::text)", name: "locations_to_tsvector_idx", using: :gin
    t.index "to_tsvector('english'::regconfig, (suburb)::text)", name: "locations_to_tsvector_idx1", using: :gin
    t.index ["postal_code", "suburb", "neighbourhood", "city", "province", "country"], name: "uniq_index", unique: true
  end

  create_table "locations_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "admin_level"
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.string "country_code"
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "osm_id"
    t.datetime "updated_at", null: false
    t.index ["bounds"], name: "index_locations_locations_on_bounds", using: :gist
    t.index ["name"], name: "index_locations_locations_on_name"
    t.index ["osm_id"], name: "index_locations_locations_on_osm_id"
  end

  create_table "locations_names", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "alternative_names"
    t.string "city"
    t.string "country"
    t.string "country_code"
    t.string "county"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.bigint "importance"
    t.string "language"
    t.uuid "location_id"
    t.string "locode"
    t.string "name"
    t.string "name_type"
    t.string "osm_class"
    t.bigint "osm_id"
    t.string "osm_type"
    t.bigint "place_rank"
    t.geometry "point", limit: {:srid=>0, :type=>"geometry"}
    t.string "postal_code"
    t.string "state"
    t.string "street"
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, (alternative_names)::text)", name: "locations_names_to_tsvector_idx8", using: :gin
    t.index "to_tsvector('english'::regconfig, (city)::text)", name: "locations_names_to_tsvector_idx10", using: :gin
    t.index "to_tsvector('english'::regconfig, (country)::text)", name: "locations_names_to_tsvector_idx1", using: :gin
    t.index "to_tsvector('english'::regconfig, (country_code)::text)", name: "locations_names_to_tsvector_idx5", using: :gin
    t.index "to_tsvector('english'::regconfig, (display_name)::text)", name: "locations_names_to_tsvector_idx6", using: :gin
    t.index "to_tsvector('english'::regconfig, (language)::text)", name: "locations_names_to_tsvector_idx3", using: :gin
    t.index "to_tsvector('english'::regconfig, (name)::text)", name: "locations_names_to_tsvector_idx7", using: :gin
    t.index "to_tsvector('english'::regconfig, (osm_id)::text)", name: "locations_names_to_tsvector_idx4", using: :gin
    t.index "to_tsvector('english'::regconfig, (postal_code)::text)", name: "locations_names_to_tsvector_idx9", using: :gin
    t.index ["language", "osm_id", "street", "country", "country_code", "display_name", "name", "postal_code"], name: "uniq_index_1", unique: true
    t.index ["locode"], name: "index_locations_names_on_locode"
    t.index ["osm_id"], name: "index_locations_names_on_osm_id"
    t.index ["osm_type"], name: "index_locations_names_on_osm_type"
  end

  create_table "mandatory_charges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "export_charges"
    t.boolean "import_charges"
    t.boolean "on_carriage"
    t.boolean "pre_carriage"
    t.datetime "updated_at", null: false
  end

  create_table "map_data", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "destination", default: [], array: true
    t.jsonb "geo_json"
    t.string "itinerary_id"
    t.jsonb "line"
    t.decimal "origin", default: [], array: true
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_map_data_on_sandbox_id"
    t.index ["tenant_id"], name: "index_map_data_on_tenant_id"
  end

  create_table "max_dimensions_bundles", force: :cascade do |t|
    t.boolean "aggregate"
    t.decimal "chargeable_weight"
    t.datetime "created_at", null: false
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.decimal "dimension_z"
    t.string "mode_of_transport"
    t.decimal "payload_in_kg"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_max_dimensions_bundles_on_sandbox_id"
    t.index ["tenant_id"], name: "index_max_dimensions_bundles_on_tenant_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id"
    t.datetime "created_at", null: false
    t.string "message"
    t.boolean "read"
    t.datetime "read_at"
    t.integer "sender_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "mot_scopes", force: :cascade do |t|
    t.boolean "air_cargo_item"
    t.boolean "air_container"
    t.datetime "created_at", null: false
    t.boolean "ocean_cargo_item"
    t.boolean "ocean_container"
    t.boolean "rail_cargo_item"
    t.boolean "rail_container"
    t.datetime "updated_at", null: false
  end

  create_table "nexuses", force: :cascade do |t|
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.float "latitude"
    t.string "locode"
    t.float "longitude"
    t.string "name"
    t.string "photo"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_nexuses_on_sandbox_id"
    t.index ["tenant_id"], name: "index_nexuses_on_tenant_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "body", comment: "MASKED WITH literal:"
    t.boolean "contains_html"
    t.datetime "created_at", null: false
    t.string "header", comment: "MASKED WITH literal:"
    t.integer "hub_id"
    t.integer "itinerary_id"
    t.string "level"
    t.uuid "pricings_pricing_id"
    t.boolean "remarks", default: false, null: false
    t.uuid "sandbox_id"
    t.integer "target_id"
    t.string "target_type"
    t.integer "tenant_id"
    t.boolean "transshipment", default: false, null: false
    t.integer "trucking_pricing_id"
    t.datetime "updated_at", null: false
    t.index ["pricings_pricing_id"], name: "index_notes_on_pricings_pricing_id"
    t.index ["remarks"], name: "index_notes_on_remarks"
    t.index ["sandbox_id"], name: "index_notes_on_sandbox_id"
    t.index ["target_type", "target_id"], name: "index_notes_on_target_type_and_target_id"
    t.index ["transshipment"], name: "index_notes_on_transshipment"
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.uuid "resource_owner_id", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "application_id"
    t.datetime "created_at", null: false
    t.integer "expires_in"
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.uuid "resource_owner_id"
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "owner_id"
    t.string "owner_type"
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "optin_statuses", force: :cascade do |t|
    t.boolean "cookies"
    t.datetime "created_at", null: false
    t.boolean "itsmycargo"
    t.uuid "sandbox_id"
    t.boolean "tenant"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_optin_statuses_on_sandbox_id"
  end

  create_table "ports", force: :cascade do |t|
    t.integer "address_id"
    t.string "code"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "name"
    t.integer "nexus_id"
    t.string "telephone"
    t.datetime "updated_at", null: false
    t.string "web"
  end

  create_table "prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.decimal "value"
    t.index ["sandbox_id"], name: "index_prices_on_sandbox_id"
  end

  create_table "pricing_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "currency_id"
    t.string "currency_name"
    t.string "hw_rate_basis"
    t.decimal "hw_threshold"
    t.decimal "min"
    t.bigint "priceable_id"
    t.string "priceable_type"
    t.jsonb "range", default: []
    t.decimal "rate"
    t.string "rate_basis"
    t.uuid "sandbox_id"
    t.string "shipping_type"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_pricing_details_on_currency_id"
    t.index ["priceable_type", "priceable_id"], name: "index_pricing_details_on_priceable_type_and_priceable_id"
    t.index ["sandbox_id"], name: "index_pricing_details_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricing_details_on_tenant_id"
  end

  create_table "pricing_exceptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.bigint "pricing_id"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["pricing_id"], name: "index_pricing_exceptions_on_pricing_id"
    t.index ["tenant_id"], name: "index_pricing_exceptions_on_tenant_id"
  end

  create_table "pricing_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "pricing_id"
    t.string "status"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["pricing_id"], name: "index_pricing_requests_on_pricing_id"
    t.index ["tenant_id"], name: "index_pricing_requests_on_tenant_id"
    t.index ["user_id"], name: "index_pricing_requests_on_user_id"
  end

  create_table "pricings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.boolean "internal", default: false
    t.bigint "itinerary_id"
    t.uuid "sandbox_id"
    t.bigint "tenant_id"
    t.integer "tenant_vehicle_id"
    t.bigint "transport_category_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.decimal "wm_rate"
    t.index ["itinerary_id"], name: "index_pricings_on_itinerary_id"
    t.index ["sandbox_id"], name: "index_pricings_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_on_tenant_id"
    t.index ["transport_category_id"], name: "index_pricings_on_transport_category_id"
    t.index ["user_id"], name: "index_pricings_on_user_id"
    t.index ["uuid"], name: "index_pricings_on_uuid", unique: true
  end

  create_table "pricings_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "charge_category_id"
    t.datetime "created_at", null: false
    t.uuid "margin_id"
    t.string "operator"
    t.uuid "sandbox_id"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.decimal "value"
    t.index ["margin_id"], name: "index_pricings_details_on_margin_id"
    t.index ["sandbox_id"], name: "index_pricings_details_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_details_on_tenant_id"
  end

  create_table "pricings_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "base"
    t.integer "charge_category_id"
    t.datetime "created_at", null: false
    t.bigint "currency_id"
    t.string "currency_name"
    t.uuid "hw_rate_basis_id"
    t.decimal "hw_threshold"
    t.integer "legacy_id"
    t.decimal "min"
    t.uuid "pricing_id"
    t.jsonb "range", default: []
    t.decimal "rate"
    t.uuid "rate_basis_id"
    t.uuid "sandbox_id"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_pricings_fees_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_fees_on_tenant_id"
  end

  create_table "pricings_margins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "applicable_id"
    t.string "applicable_type"
    t.integer "application_order", default: 0
    t.string "cargo_class"
    t.datetime "created_at", null: false
    t.string "default_for"
    t.integer "destination_hub_id"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.integer "itinerary_id"
    t.integer "margin_type"
    t.string "operator"
    t.integer "origin_hub_id"
    t.uuid "pricing_id"
    t.uuid "sandbox_id"
    t.uuid "tenant_id"
    t.integer "tenant_vehicle_id"
    t.datetime "updated_at", null: false
    t.decimal "value"
    t.index ["applicable_type", "applicable_id"], name: "index_pricings_margins_on_applicable_type_and_applicable_id"
    t.index ["application_order"], name: "index_pricings_margins_on_application_order"
    t.index ["cargo_class"], name: "index_pricings_margins_on_cargo_class"
    t.index ["destination_hub_id"], name: "index_pricings_margins_on_destination_hub_id"
    t.index ["effective_date"], name: "index_pricings_margins_on_effective_date"
    t.index ["expiration_date"], name: "index_pricings_margins_on_expiration_date"
    t.index ["itinerary_id"], name: "index_pricings_margins_on_itinerary_id"
    t.index ["origin_hub_id"], name: "index_pricings_margins_on_origin_hub_id"
    t.index ["pricing_id"], name: "index_pricings_margins_on_pricing_id"
    t.index ["sandbox_id"], name: "index_pricings_margins_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_margins_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_pricings_margins_on_tenant_vehicle_id"
  end

  create_table "pricings_pricings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cargo_class"
    t.datetime "created_at", null: false
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.uuid "group_id"
    t.boolean "internal", default: false
    t.bigint "itinerary_id"
    t.integer "legacy_id"
    t.string "load_type"
    t.uuid "sandbox_id"
    t.bigint "tenant_id"
    t.integer "tenant_vehicle_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.decimal "wm_rate"
    t.index ["cargo_class"], name: "index_pricings_pricings_on_cargo_class"
    t.index ["itinerary_id"], name: "index_pricings_pricings_on_itinerary_id"
    t.index ["load_type"], name: "index_pricings_pricings_on_load_type"
    t.index ["sandbox_id"], name: "index_pricings_pricings_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_pricings_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_pricings_pricings_on_tenant_vehicle_id"
    t.index ["user_id"], name: "index_pricings_pricings_on_user_id"
  end

  create_table "pricings_rate_bases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "external_code"
    t.string "internal_code"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.index ["external_code"], name: "index_pricings_rate_bases_on_external_code"
    t.index ["sandbox_id"], name: "index_pricings_rate_bases_on_sandbox_id"
  end

  create_table "quotations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "original_shipment_id"
    t.uuid "sandbox_id"
    t.string "target_email"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["sandbox_id"], name: "index_quotations_on_sandbox_id"
  end

  create_table "quotations_line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount_cents"
    t.string "amount_currency"
    t.bigint "charge_category_id"
    t.datetime "created_at", null: false
    t.uuid "tender_id"
    t.datetime "updated_at", null: false
    t.index ["charge_category_id"], name: "index_quotations_line_items_on_charge_category_id"
    t.index ["tender_id"], name: "index_quotations_line_items_on_tender_id"
  end

  create_table "quotations_quotations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "destination_nexus_id"
    t.integer "origin_nexus_id"
    t.bigint "sandbox_id"
    t.datetime "selected_date"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["destination_nexus_id"], name: "index_quotations_quotations_on_destination_nexus_id"
    t.index ["origin_nexus_id"], name: "index_quotations_quotations_on_origin_nexus_id"
    t.index ["sandbox_id"], name: "index_quotations_quotations_on_sandbox_id"
    t.index ["tenant_id"], name: "index_quotations_quotations_on_tenant_id"
    t.index ["user_id"], name: "index_quotations_quotations_on_user_id"
  end

  create_table "quotations_tenders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount_cents"
    t.string "amount_currency"
    t.string "carrier_name"
    t.datetime "created_at", null: false
    t.integer "destination_hub_id"
    t.string "load_type"
    t.string "name"
    t.integer "origin_hub_id"
    t.uuid "quotation_id"
    t.bigint "tenant_vehicle_id"
    t.datetime "updated_at", null: false
    t.index ["destination_hub_id"], name: "index_quotations_tenders_on_destination_hub_id"
    t.index ["origin_hub_id"], name: "index_quotations_tenders_on_origin_hub_id"
    t.index ["quotation_id"], name: "index_quotations_tenders_on_quotation_id"
    t.index ["tenant_vehicle_id"], name: "index_quotations_tenders_on_tenant_vehicle_id"
  end

  create_table "rate_bases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_code"
    t.string "internal_code"
    t.datetime "updated_at", null: false
  end

  create_table "remarks", force: :cascade do |t|
    t.string "body"
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "order"
    t.uuid "sandbox_id"
    t.string "subcategory"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_remarks_on_sandbox_id"
    t.index ["tenant_id"], name: "index_remarks_on_tenant_id"
  end

  create_table "rms_data_books", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "book_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.integer "sheet_type"
    t.uuid "target_id"
    t.string "target_type"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sheet_type"], name: "index_rms_data_books_on_sheet_type"
    t.index ["target_type", "target_id"], name: "index_rms_data_books_on_target_type_and_target_id"
    t.index ["tenant_id"], name: "index_rms_data_books_on_tenant_id"
  end

  create_table "rms_data_cells", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "column"
    t.datetime "created_at", null: false
    t.integer "row"
    t.uuid "sheet_id"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["column"], name: "index_rms_data_cells_on_column"
    t.index ["row"], name: "index_rms_data_cells_on_row"
    t.index ["sheet_id"], name: "index_rms_data_cells_on_sheet_id"
    t.index ["tenant_id"], name: "index_rms_data_cells_on_tenant_id"
  end

  create_table "rms_data_sheets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "book_id"
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.string "name"
    t.integer "sheet_index"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_rms_data_sheets_on_book_id"
    t.index ["sheet_index"], name: "index_rms_data_sheets_on_sheet_index"
    t.index ["tenant_id"], name: "index_rms_data_sheets_on_tenant_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "routing_carriers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "abbreviated_name"
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name", "code", "abbreviated_name"], name: "routing_carriers_index", unique: true
  end

  create_table "routing_line_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id"
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["carrier_id", "name"], name: "line_service_unique_index", unique: true
    t.index ["carrier_id"], name: "index_routing_line_services_on_carrier_id"
  end

  create_table "routing_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.geometry "center", limit: {:srid=>0, :type=>"geometry"}
    t.string "country_code"
    t.datetime "created_at", null: false
    t.string "locode"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["bounds"], name: "index_routing_locations_on_bounds", using: :gist
    t.index ["center"], name: "index_routing_locations_on_center"
    t.index ["locode"], name: "index_routing_locations_on_locode"
  end

  create_table "routing_route_line_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "line_service_id"
    t.uuid "route_id"
    t.datetime "updated_at", null: false
    t.index ["route_id", "line_service_id"], name: "route_line_service_index", unique: true
  end

  create_table "routing_routes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "allowed_cargo", default: 0, null: false
    t.datetime "created_at", null: false
    t.uuid "destination_id"
    t.uuid "destination_terminal_id"
    t.integer "mode_of_transport", default: 0, null: false
    t.uuid "origin_id"
    t.uuid "origin_terminal_id"
    t.decimal "price_factor"
    t.decimal "time_factor"
    t.datetime "updated_at", null: false
    t.index ["origin_id", "destination_id", "origin_terminal_id", "destination_terminal_id", "mode_of_transport"], name: "routing_routes_index", unique: true
  end

  create_table "routing_terminals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.geometry "center", limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.uuid "location_id"
    t.integer "mode_of_transport", default: 0
    t.string "terminal_code"
    t.datetime "updated_at", null: false
    t.index ["center"], name: "index_routing_terminals_on_center"
  end

  create_table "routing_transit_times", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "days"
    t.uuid "route_line_service_id"
    t.datetime "updated_at", null: false
  end

  create_table "schema_migration_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction"
    t.integer "duration"
    t.string "git_version"
    t.string "hostname"
    t.string "name"
    t.string "rails_version"
    t.string "version", null: false
    t.index ["version"], name: "index_schema_migration_details_on_version"
  end

  create_table "sequential_sequences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "name"
    t.datetime "updated_at", null: false
    t.bigint "value", default: 0
  end

  create_table "shipment_contacts", force: :cascade do |t|
    t.integer "contact_id"
    t.string "contact_type"
    t.datetime "created_at", null: false
    t.uuid "sandbox_id"
    t.integer "shipment_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_shipment_contacts_on_sandbox_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.datetime "booking_placed_at"
    t.string "cargo_notes"
    t.datetime "closing_date"
    t.datetime "created_at", null: false
    t.jsonb "customs"
    t.boolean "customs_credit", default: false
    t.datetime "desired_start_date"
    t.integer "destination_hub_id"
    t.integer "destination_nexus_id"
    t.string "direction"
    t.string "eori"
    t.boolean "has_on_carriage"
    t.boolean "has_pre_carriage"
    t.string "imc_reference"
    t.integer "incoterm_id"
    t.string "incoterm_text"
    t.jsonb "insurance"
    t.integer "itinerary_id"
    t.string "load_type"
    t.jsonb "meta", default: {}
    t.string "notes"
    t.integer "origin_hub_id"
    t.integer "origin_nexus_id"
    t.datetime "planned_delivery_date"
    t.datetime "planned_destination_collection_date"
    t.datetime "planned_eta"
    t.datetime "planned_etd"
    t.datetime "planned_origin_drop_off_date"
    t.datetime "planned_pickup_date"
    t.integer "quotation_id"
    t.uuid "sandbox_id"
    t.string "status"
    t.integer "tenant_id"
    t.jsonb "total_goods_value"
    t.bigint "transport_category_id"
    t.integer "trip_id"
    t.jsonb "trucking"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "uuid"
    t.index ["sandbox_id"], name: "index_shipments_on_sandbox_id"
    t.index ["tenant_id"], name: "index_shipments_on_tenant_id"
    t.index ["transport_category_id"], name: "index_shipments_on_transport_category_id"
  end

  create_table "stops", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "hub_id"
    t.integer "index"
    t.integer "itinerary_id"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_stops_on_sandbox_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "model"
    t.string "model_id"
    t.string "name"
    t.string "tag_type"
    t.datetime "updated_at", null: false
  end

  create_table "tenant_cargo_item_types", force: :cascade do |t|
    t.bigint "cargo_item_type_id"
    t.datetime "created_at", null: false
    t.uuid "sandbox_id"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["cargo_item_type_id"], name: "index_tenant_cargo_item_types_on_cargo_item_type_id"
    t.index ["sandbox_id"], name: "index_tenant_cargo_item_types_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenant_cargo_item_types_on_tenant_id"
  end

  create_table "tenant_incoterms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "incoterm_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenant_incoterms_on_tenant_id"
  end

  create_table "tenant_routing_connections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "inbound_id"
    t.uuid "line_service_id"
    t.integer "mode_of_transport", default: 0
    t.uuid "outbound_id"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["inbound_id"], name: "index_tenant_routing_connections_on_inbound_id"
    t.index ["outbound_id"], name: "index_tenant_routing_connections_on_outbound_id"
    t.index ["tenant_id"], name: "index_tenant_routing_connections_on_tenant_id"
  end

  create_table "tenant_routing_routes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "line_service_id"
    t.integer "mode_of_transport", default: 0
    t.integer "price_factor"
    t.uuid "route_id"
    t.uuid "tenant_id"
    t.integer "time_factor"
    t.datetime "updated_at", null: false
    t.index ["line_service_id"], name: "index_tenant_routing_routes_on_line_service_id"
    t.index ["mode_of_transport"], name: "index_tenant_routing_routes_on_mode_of_transport"
    t.index ["tenant_id"], name: "index_tenant_routing_routes_on_tenant_id"
  end

  create_table "tenant_routing_visibilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "connection_id"
    t.datetime "created_at", null: false
    t.uuid "target_id"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "visibility_connection_index"
    t.index ["target_type", "target_id"], name: "visibility_target_index"
  end

  create_table "tenant_vehicles", force: :cascade do |t|
    t.integer "carrier_id"
    t.datetime "created_at", null: false
    t.boolean "is_default"
    t.string "mode_of_transport"
    t.string "name"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.integer "vehicle_id"
    t.index ["sandbox_id"], name: "index_tenant_vehicles_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenant_vehicles_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.jsonb "addresses"
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR"
    t.jsonb "email_links"
    t.jsonb "emails"
    t.string "name"
    t.jsonb "phones"
    t.jsonb "scope"
    t.string "subdomain"
    t.jsonb "theme"
    t.datetime "updated_at", null: false
    t.jsonb "web"
  end

  create_table "tenants_companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "address_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email"
    t.string "external_id"
    t.string "name"
    t.string "phone"
    t.uuid "sandbox_id"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.string "vat_number"
    t.index ["sandbox_id"], name: "index_tenants_companies_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenants_companies_on_tenant_id"
  end

  create_table "tenants_domains", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "default"
    t.string "domain"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenants_domains_on_tenant_id"
  end

  create_table "tenants_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "sandbox_id"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_tenants_groups_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenants_groups_on_tenant_id"
  end

  create_table "tenants_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "group_id"
    t.uuid "member_id"
    t.string "member_type"
    t.integer "priority", default: 0
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.index ["member_type", "member_id"], name: "index_tenants_memberships_on_member_type_and_member_id"
    t.index ["sandbox_id"], name: "index_tenants_memberships_on_sandbox_id"
  end

  create_table "tenants_sandboxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenants_sandboxes_on_tenant_id"
  end

  create_table "tenants_scopes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.uuid "sandbox_id"
    t.uuid "target_id"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_tenants_scopes_on_sandbox_id"
    t.index ["target_type", "target_id"], name: "index_tenants_scopes_on_target_type_and_target_id"
  end

  create_table "tenants_tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "legacy_id"
    t.string "slug"
    t.string "subdomain"
    t.datetime "updated_at", null: false
  end

  create_table "tenants_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "access_count_to_reset_password_page", default: 0
    t.string "activation_state"
    t.string "activation_token"
    t.datetime "activation_token_expires_at"
    t.uuid "company_id"
    t.datetime "created_at", null: false
    t.string "crypted_password"
    t.datetime "deleted_at"
    t.string "email", null: false
    t.integer "failed_logins_count", default: 0
    t.datetime "last_activity_at"
    t.datetime "last_login_at"
    t.string "last_login_from_ip_address"
    t.datetime "last_logout_at"
    t.integer "legacy_id"
    t.datetime "lock_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.string "salt"
    t.uuid "sandbox_id"
    t.uuid "tenant_id"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["activation_token"], name: "index_tenants_users_on_activation_token"
    t.index ["email", "tenant_id"], name: "index_tenants_users_on_email_and_tenant_id", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_tenants_users_on_last_logout_at_and_last_activity_at"
    t.index ["reset_password_token"], name: "index_tenants_users_on_reset_password_token"
    t.index ["sandbox_id"], name: "index_tenants_users_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenants_users_on_tenant_id"
    t.index ["unlock_token"], name: "index_tenants_users_on_unlock_token"
  end

  create_table "transport_categories", force: :cascade do |t|
    t.string "cargo_class"
    t.datetime "created_at", null: false
    t.string "load_type"
    t.string "mode_of_transport"
    t.string "name"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.integer "vehicle_id"
    t.index ["sandbox_id"], name: "index_transport_categories_on_sandbox_id"
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "closing_date"
    t.datetime "created_at", null: false
    t.datetime "end_date"
    t.integer "itinerary_id"
    t.string "load_type"
    t.uuid "sandbox_id"
    t.datetime "start_date"
    t.integer "tenant_vehicle_id"
    t.datetime "updated_at", null: false
    t.string "vessel"
    t.string "voyage_code"
    t.index ["closing_date"], name: "index_trips_on_closing_date"
    t.index ["itinerary_id"], name: "index_trips_on_itinerary_id"
    t.index ["sandbox_id"], name: "index_trips_on_sandbox_id"
    t.index ["tenant_vehicle_id"], name: "index_trips_on_tenant_vehicle_id"
  end

  create_table "truck_type_availabilities", force: :cascade do |t|
    t.string "carriage"
    t.datetime "created_at", null: false
    t.string "load_type"
    t.string "truck_type"
    t.datetime "updated_at", null: false
  end

  create_table "trucking_couriers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_trucking_couriers_on_sandbox_id"
    t.index ["tenant_id"], name: "index_trucking_couriers_on_tenant_id"
  end

  create_table "trucking_coverages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at", null: false
    t.integer "hub_id"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.index ["bounds"], name: "index_trucking_coverages_on_bounds", using: :gist
    t.index ["sandbox_id"], name: "index_trucking_coverages_on_sandbox_id"
  end

  create_table "trucking_destinations", force: :cascade do |t|
    t.string "city_name"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.integer "distance"
    t.integer "location_id"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.string "zipcode"
    t.index ["city_name"], name: "index_trucking_destinations_on_city_name"
    t.index ["country_code"], name: "index_trucking_destinations_on_country_code"
    t.index ["distance"], name: "index_trucking_destinations_on_distance"
    t.index ["sandbox_id"], name: "index_trucking_destinations_on_sandbox_id"
    t.index ["zipcode"], name: "index_trucking_destinations_on_zipcode"
  end

  create_table "trucking_hub_availabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "hub_id"
    t.uuid "sandbox_id"
    t.uuid "type_availability_id"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_trucking_hub_availabilities_on_sandbox_id"
  end

  create_table "trucking_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city_name"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.integer "distance"
    t.uuid "location_id"
    t.uuid "sandbox_id"
    t.datetime "updated_at", null: false
    t.string "zipcode"
    t.index ["city_name"], name: "index_trucking_locations_on_city_name"
    t.index ["country_code"], name: "index_trucking_locations_on_country_code"
    t.index ["distance"], name: "index_trucking_locations_on_distance"
    t.index ["location_id"], name: "index_trucking_locations_on_location_id"
    t.index ["sandbox_id"], name: "index_trucking_locations_on_sandbox_id"
    t.index ["zipcode"], name: "index_trucking_locations_on_zipcode"
  end

  create_table "trucking_pricing_scopes", force: :cascade do |t|
    t.string "cargo_class"
    t.string "carriage"
    t.integer "courier_id"
    t.datetime "created_at", null: false
    t.string "load_type"
    t.string "truck_type"
    t.datetime "updated_at", null: false
  end

  create_table "trucking_pricings", force: :cascade do |t|
    t.integer "cbm_ratio"
    t.datetime "created_at"
    t.jsonb "fees"
    t.string "identifier_modifier"
    t.jsonb "load_meterage"
    t.string "modifier"
    t.jsonb "rates"
    t.integer "tenant_id"
    t.integer "trucking_pricing_scope_id"
    t.datetime "updated_at"
    t.index ["tenant_id"], name: "index_trucking_pricings_on_tenant_id"
    t.index ["trucking_pricing_scope_id"], name: "index_trucking_pricings_on_trucking_pricing_scope_id"
  end

  create_table "trucking_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "cbm_ratio"
    t.datetime "created_at", null: false
    t.jsonb "fees"
    t.string "identifier_modifier"
    t.jsonb "load_meterage"
    t.string "modifier"
    t.jsonb "rates"
    t.uuid "scope_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["scope_id"], name: "index_trucking_rates_on_trucking_scope_id"
    t.index ["tenant_id"], name: "index_trucking_rates_on_tenant_id"
  end

  create_table "trucking_scopes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cargo_class"
    t.string "carriage"
    t.uuid "courier_id"
    t.datetime "created_at", null: false
    t.string "load_type"
    t.string "truck_type"
    t.datetime "updated_at", null: false
  end

  create_table "trucking_truckings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cargo_class"
    t.string "carriage"
    t.integer "cbm_ratio"
    t.uuid "courier_id"
    t.datetime "created_at", null: false
    t.jsonb "fees"
    t.uuid "group_id"
    t.integer "hub_id"
    t.string "identifier_modifier"
    t.jsonb "load_meterage"
    t.string "load_type"
    t.uuid "location_id"
    t.string "modifier"
    t.uuid "parent_id"
    t.uuid "rate_id"
    t.jsonb "rates"
    t.uuid "sandbox_id"
    t.integer "tenant_id"
    t.string "truck_type"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["hub_id"], name: "index_trucking_truckings_on_hub_id"
    t.index ["location_id"], name: "index_trucking_truckings_on_location_id"
    t.index ["rate_id", "location_id", "hub_id"], name: "trucking_foreign_keys", unique: true
    t.index ["sandbox_id"], name: "index_trucking_truckings_on_sandbox_id"
    t.index ["tenant_id"], name: "index_trucking_truckings_on_tenant_id"
  end

  create_table "trucking_type_availabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "carriage"
    t.datetime "created_at", null: false
    t.string "load_type"
    t.integer "query_method"
    t.uuid "sandbox_id"
    t.string "truck_type"
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_trucking_type_availabilities_on_sandbox_id"
  end

  create_table "user_addresses", force: :cascade do |t|
    t.integer "address_id"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.boolean "primary", default: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["deleted_at"], name: "index_user_addresses_on_deleted_at"
  end

  create_table "user_managers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "manager_id"
    t.string "section"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "users", comment: "FILTER WITH users.email NOT LIKE '%@itsmycargo.com' AND users.email NOT LIKE '%demo%@%'", force: :cascade do |t|
    t.integer "agency_id"
    t.boolean "allow_password_change", default: false, null: false
    t.string "company_name"
    t.string "company_number"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR"
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.datetime "deleted_at"
    t.string "email", comment: "MASKED WITH EmailAddress"
    t.string "encrypted_password", default: "", null: false
    t.string "external_id"
    t.string "first_name", comment: "MASKED WITH FirstName"
    t.boolean "guest", default: false
    t.string "image"
    t.boolean "internal", default: false
    t.string "last_name", comment: "MASKED WITH LastName"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "nickname"
    t.jsonb "optin_status", default: {}
    t.integer "optin_status_id"
    t.string "phone", comment: "MASKED WITH Phone"
    t.string "provider", default: "tenant_email", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.bigint "role_id"
    t.uuid "sandbox_id"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "tenant_id"
    t.json "tokens"
    t.string "uid", default: "", null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.string "vat_number"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["sandbox_id"], name: "index_users_on_sandbox_id"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "users_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "google_id"
    t.datetime "last_activity_at"
    t.datetime "last_login_at"
    t.string "last_login_from_ip_address"
    t.datetime "last_logout_at"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "vehicles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "mode_of_transport"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "versions", comment: "IGNORE DATA", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.jsonb "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "address_book_contacts", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "address_book_contacts", "tenants_users", column: "user_id"
  add_foreign_key "cargo_units", "cargo_cargos", column: "cargo_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "quotations_tenders", "quotations_quotations", column: "quotation_id"
  add_foreign_key "remarks", "tenants"
  add_foreign_key "shipments", "transport_categories"
  add_foreign_key "tenant_cargo_item_types", "cargo_item_types"
  add_foreign_key "tenant_cargo_item_types", "tenants"
  add_foreign_key "users", "roles"
end
