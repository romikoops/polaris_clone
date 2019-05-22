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

ActiveRecord::Schema.define(version: 2019_05_20_125100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_tiger_geocoder"
  enable_extension "postgis_topology"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addons", force: :cascade do |t|
    t.string "title"
    t.jsonb "text", default: [], array: true
    t.integer "tenant_id"
    t.string "read_more"
    t.string "accept_text"
    t.string "decline_text"
    t.string "additional_info_text"
    t.string "cargo_class"
    t.integer "hub_id"
    t.integer "counterpart_hub_id"
    t.string "mode_of_transport"
    t.integer "tenant_vehicle_id"
    t.string "direction"
    t.string "addon_type"
    t.jsonb "fees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "addresses", force: :cascade do |t|
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

  create_table "agencies", force: :cascade do |t|
    t.string "name"
    t.integer "tenant_id"
    t.integer "agency_manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "aggregated_cargos", force: :cascade do |t|
    t.decimal "weight"
    t.decimal "volume"
    t.decimal "chargeable_weight"
    t.integer "shipment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alternative_names", force: :cascade do |t|
    t.string "model"
    t.string "model_id"
    t.string "name"
    t.string "locale"
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

  create_table "carriers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "charge_breakdowns", force: :cascade do |t|
    t.integer "shipment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trip_id"
  end

  create_table "charge_categories", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "cargo_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_id"
  end

  create_table "charges", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "price_id"
    t.integer "charge_category_id"
    t.integer "children_charge_category_id"
    t.integer "charge_breakdown_id"
    t.integer "detail_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "edited_price_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "address_id"
    t.string "company_name"
    t.string "first_name", comment: "MASKED WITH FirstName"
    t.string "last_name", comment: "MASKED WITH LastName"
    t.string "phone", comment: "MASKED WITH Phone"
    t.string "email", comment: "MASKED WITH EmailAddress"
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

  create_table "contents", force: :cascade do |t|
    t.jsonb "text", default: {}
    t.string "component"
    t.string "section"
    t.integer "index"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "tenant_id"
  end

  create_table "customs_fees", force: :cascade do |t|
    t.string "mode_of_transport"
    t.string "load_type"
    t.integer "hub_id"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_vehicle_id"
    t.integer "counterpart_hub_id"
    t.string "direction"
    t.jsonb "fees"
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
    t.integer "quotation_id"
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

  create_table "hub_truck_type_availabilities", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "truck_type_availability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hub_truckings", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "trucking_destination_id"
    t.integer "trucking_pricing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hub_id"], name: "index_hub_truckings_on_hub_id"
    t.index ["trucking_pricing_id", "trucking_destination_id", "hub_id"], name: "foreign_keys", unique: true
  end

  create_table "hubs", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "address_id"
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
    t.index ["mode_of_transport"], name: "index_itineraries_on_mode_of_transport"
    t.index ["name"], name: "index_itineraries_on_name"
    t.index ["tenant_id"], name: "index_itineraries_on_tenant_id"
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
    t.string "mode_of_transport"
    t.string "load_type"
    t.integer "hub_id"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_vehicle_id"
    t.integer "counterpart_hub_id"
    t.string "direction"
    t.jsonb "fees"
    t.boolean "dangerous", default: false
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.integer "user_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["uuid"], name: "index_local_charges_on_uuid", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "postal_code"
    t.string "suburb"
    t.string "neighbourhood"
    t.string "city"
    t.string "province"
    t.string "country"
    t.string "admin_level"
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.index "to_tsvector('english'::regconfig, (city)::text)", name: "locations_to_tsvector_idx3", using: :gin
    t.index "to_tsvector('english'::regconfig, (country)::text)", name: "locations_to_tsvector_idx4", using: :gin
    t.index "to_tsvector('english'::regconfig, (neighbourhood)::text)", name: "locations_to_tsvector_idx2", using: :gin
    t.index "to_tsvector('english'::regconfig, (postal_code)::text)", name: "locations_to_tsvector_idx", using: :gin
    t.index "to_tsvector('english'::regconfig, (suburb)::text)", name: "locations_to_tsvector_idx1", using: :gin
    t.index ["postal_code", "suburb", "neighbourhood", "city", "province", "country"], name: "uniq_index", unique: true
  end

  create_table "locations_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.bigint "osm_id"
    t.string "name"
    t.integer "admin_level"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bounds"], name: "index_locations_locations_on_bounds", using: :gist
    t.index ["name"], name: "index_locations_locations_on_name"
    t.index ["osm_id"], name: "index_locations_locations_on_osm_id"
  end

  create_table "locations_names", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "language"
    t.uuid "location_id"
    t.bigint "osm_id"
    t.bigint "place_rank"
    t.bigint "importance"
    t.string "osm_type"
    t.string "street"
    t.string "city"
    t.string "osm_class"
    t.string "name_type"
    t.string "country"
    t.string "county"
    t.string "state"
    t.string "country_code"
    t.string "display_name"
    t.string "alternative_names"
    t.string "name"
    t.geometry "point", limit: {:srid=>0, :type=>"geometry"}
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locode"
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
    t.boolean "pre_carriage"
    t.boolean "on_carriage"
    t.boolean "import_charges"
    t.boolean "export_charges"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "map_data", force: :cascade do |t|
    t.jsonb "line"
    t.jsonb "geo_json"
    t.decimal "origin", default: [], array: true
    t.decimal "destination", default: [], array: true
    t.string "itinerary_id"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "max_dimensions_bundles", force: :cascade do |t|
    t.string "mode_of_transport"
    t.integer "tenant_id"
    t.boolean "aggregate"
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.decimal "dimension_z"
    t.decimal "payload_in_kg"
    t.decimal "chargeable_weight"
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

  create_table "nexuses", force: :cascade do |t|
    t.string "name"
    t.integer "tenant_id"
    t.float "latitude"
    t.float "longitude"
    t.string "photo"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notes", force: :cascade do |t|
    t.integer "itinerary_id"
    t.integer "hub_id"
    t.integer "trucking_pricing_id"
    t.string "body", comment: "MASKED WITH literal:"
    t.string "header", comment: "MASKED WITH literal:"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id", null: false
    t.uuid "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id"
    t.uuid "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "owner_id"
    t.string "owner_type"
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "optin_statuses", force: :cascade do |t|
    t.boolean "cookies"
    t.boolean "tenant"
    t.boolean "itsmycargo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ports", force: :cascade do |t|
    t.integer "country_id"
    t.string "name"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "telephone"
    t.string "web"
    t.string "code"
    t.integer "nexus_id"
    t.integer "address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prices", force: :cascade do |t|
    t.decimal "value"
    t.string "currency"
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

  create_table "pricing_requests", force: :cascade do |t|
    t.integer "pricing_id"
    t.integer "user_id"
    t.integer "tenant_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pricing_id"], name: "index_pricing_requests_on_pricing_id"
    t.index ["tenant_id"], name: "index_pricing_requests_on_tenant_id"
    t.index ["user_id"], name: "index_pricing_requests_on_user_id"
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
    t.integer "tenant_vehicle_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["itinerary_id"], name: "index_pricings_on_itinerary_id"
    t.index ["tenant_id"], name: "index_pricings_on_tenant_id"
    t.index ["transport_category_id"], name: "index_pricings_on_transport_category_id"
    t.index ["user_id"], name: "index_pricings_on_user_id"
    t.index ["uuid"], name: "index_pricings_on_uuid", unique: true
  end

  create_table "pricings_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.uuid "margin_id"
    t.decimal "value"
    t.string "operator"
    t.integer "charge_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["margin_id"], name: "index_pricings_details_on_margin_id"
    t.index ["tenant_id"], name: "index_pricings_details_on_tenant_id"
  end

  create_table "pricings_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "rate"
    t.decimal "base"
    t.uuid "rate_basis_id"
    t.decimal "min"
    t.decimal "hw_threshold"
    t.uuid "hw_rate_basis_id"
    t.integer "charge_category_id"
    t.jsonb "range", default: []
    t.string "currency_name"
    t.bigint "currency_id"
    t.uuid "pricing_id"
    t.bigint "tenant_id"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "trucking_rates", default: {}
    t.jsonb "trucking_conversions", default: {}
  end

  create_table "pricings_margins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.uuid "pricing_id"
    t.string "default_for"
    t.string "operator"
    t.decimal "value"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.string "applicable_type"
    t.uuid "applicable_id"
    t.integer "tenant_vehicle_id"
    t.string "cargo_class"
    t.integer "itinerary_id"
    t.integer "origin_hub_id"
    t.integer "destination_hub_id"
    t.integer "application_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "margin_type"
    t.index ["applicable_type", "applicable_id"], name: "index_pricings_margins_on_applicable_type_and_applicable_id"
    t.index ["application_order"], name: "index_pricings_margins_on_application_order"
    t.index ["cargo_class"], name: "index_pricings_margins_on_cargo_class"
    t.index ["destination_hub_id"], name: "index_pricings_margins_on_destination_hub_id"
    t.index ["effective_date"], name: "index_pricings_margins_on_effective_date"
    t.index ["expiration_date"], name: "index_pricings_margins_on_expiration_date"
    t.index ["itinerary_id"], name: "index_pricings_margins_on_itinerary_id"
    t.index ["origin_hub_id"], name: "index_pricings_margins_on_origin_hub_id"
    t.index ["pricing_id"], name: "index_pricings_margins_on_pricing_id"
    t.index ["tenant_id"], name: "index_pricings_margins_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_pricings_margins_on_tenant_vehicle_id"
  end

  create_table "pricings_pricings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "wm_rate"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.bigint "tenant_id"
    t.string "cargo_class"
    t.string "load_type"
    t.bigint "user_id"
    t.bigint "itinerary_id"
    t.integer "tenant_vehicle_id"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "disabled", default: false
    t.index ["cargo_class"], name: "index_pricings_pricings_on_cargo_class"
    t.index ["itinerary_id"], name: "index_pricings_pricings_on_itinerary_id"
    t.index ["load_type"], name: "index_pricings_pricings_on_load_type"
    t.index ["tenant_id"], name: "index_pricings_pricings_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_pricings_pricings_on_tenant_vehicle_id"
    t.index ["user_id"], name: "index_pricings_pricings_on_user_id"
  end

  create_table "pricings_rate_bases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_code"
    t.string "internal_code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_code"], name: "index_pricings_rate_bases_on_external_code"
  end

  create_table "quotations", force: :cascade do |t|
    t.string "target_email"
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "original_shipment_id"
  end

  create_table "rate_bases", force: :cascade do |t|
    t.string "external_code"
    t.string "internal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "remarks", force: :cascade do |t|
    t.bigint "tenant_id"
    t.string "category"
    t.string "subcategory"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.index ["tenant_id"], name: "index_remarks_on_tenant_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schema_migration_details", force: :cascade do |t|
    t.string "version", null: false
    t.string "name"
    t.string "hostname"
    t.string "git_version"
    t.string "rails_version"
    t.integer "duration"
    t.string "direction"
    t.datetime "created_at", null: false
    t.index ["version"], name: "index_schema_migration_details_on_version"
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
    t.string "uuid"
    t.string "imc_reference"
    t.string "status"
    t.string "load_type"
    t.datetime "planned_pickup_date"
    t.boolean "has_pre_carriage"
    t.boolean "has_on_carriage"
    t.string "cargo_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_id"
    t.datetime "planned_eta"
    t.datetime "planned_etd"
    t.integer "itinerary_id"
    t.jsonb "trucking"
    t.boolean "customs_credit", default: false
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
    t.datetime "closing_date"
    t.string "incoterm_text"
    t.integer "origin_nexus_id"
    t.integer "destination_nexus_id"
    t.datetime "planned_origin_drop_off_date"
    t.integer "quotation_id"
    t.datetime "planned_delivery_date"
    t.datetime "planned_destination_collection_date"
    t.datetime "desired_start_date"
    t.jsonb "meta", default: {}
    t.index ["transport_category_id"], name: "index_shipments_on_transport_category_id"
  end

  create_table "stops", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "itinerary_id"
    t.integer "index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "tag_type"
    t.string "name"
    t.string "model"
    t.string "model_id"
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
    t.integer "carrier_id"
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

  create_table "tenants_companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "address_id"
    t.string "vat_number"
    t.string "email"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.string "phone"
  end

  create_table "tenants_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenants_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "member_type"
    t.uuid "member_id"
    t.uuid "group_id"
    t.integer "priority", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_type", "member_id"], name: "index_tenants_memberships_on_member_type_and_member_id"
  end

  create_table "tenants_scopes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "target_type"
    t.uuid "target_id"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_type", "target_id"], name: "index_tenants_scopes_on_target_type_and_target_id"
  end

  create_table "tenants_tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subdomain"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenants_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "activation_state"
    t.string "activation_token"
    t.datetime "activation_token_expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.integer "failed_logins_count", default: 0
    t.datetime "lock_expires_at"
    t.string "unlock_token"
    t.integer "legacy_id"
    t.uuid "tenant_id"
    t.uuid "company_id"
    t.index ["activation_token"], name: "index_tenants_users_on_activation_token"
    t.index ["email", "tenant_id"], name: "index_tenants_users_on_email_and_tenant_id", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_tenants_users_on_last_logout_at_and_last_activity_at"
    t.index ["reset_password_token"], name: "index_tenants_users_on_reset_password_token"
    t.index ["unlock_token"], name: "index_tenants_users_on_unlock_token"
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
    t.string "load_type"
    t.index ["closing_date"], name: "index_trips_on_closing_date"
    t.index ["itinerary_id"], name: "index_trips_on_itinerary_id"
    t.index ["tenant_vehicle_id"], name: "index_trips_on_tenant_vehicle_id"
  end

  create_table "truck_type_availabilities", force: :cascade do |t|
    t.string "load_type"
    t.string "carriage"
    t.string "truck_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_couriers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_coverages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "hub_id"
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bounds"], name: "index_trucking_coverages_on_bounds", using: :gist
  end

  create_table "trucking_destinations", force: :cascade do |t|
    t.string "zipcode"
    t.string "country_code"
    t.string "city_name"
    t.integer "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.index ["city_name"], name: "index_trucking_destinations_on_city_name"
    t.index ["country_code"], name: "index_trucking_destinations_on_country_code"
    t.index ["distance"], name: "index_trucking_destinations_on_distance"
    t.index ["zipcode"], name: "index_trucking_destinations_on_zipcode"
  end

  create_table "trucking_hub_availabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "hub_id"
    t.uuid "type_availability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "zipcode"
    t.string "country_code"
    t.string "city_name"
    t.integer "distance"
    t.uuid "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_name"], name: "index_trucking_locations_on_city_name"
    t.index ["country_code"], name: "index_trucking_locations_on_country_code"
    t.index ["distance"], name: "index_trucking_locations_on_distance"
    t.index ["location_id"], name: "index_trucking_locations_on_location_id"
    t.index ["zipcode"], name: "index_trucking_locations_on_zipcode"
  end

  create_table "trucking_pricing_scopes", force: :cascade do |t|
    t.string "load_type"
    t.string "cargo_class"
    t.string "carriage"
    t.integer "courier_id"
    t.string "truck_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_pricings", force: :cascade do |t|
    t.jsonb "load_meterage"
    t.integer "cbm_ratio"
    t.string "modifier"
    t.integer "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.jsonb "rates"
    t.jsonb "fees"
    t.string "identifier_modifier"
    t.integer "trucking_pricing_scope_id"
    t.index ["trucking_pricing_scope_id"], name: "index_trucking_pricings_on_trucking_pricing_scope_id"
  end

  create_table "trucking_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "load_meterage"
    t.integer "cbm_ratio"
    t.string "modifier"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "rates"
    t.jsonb "fees"
    t.string "identifier_modifier"
    t.uuid "scope_id"
    t.index ["scope_id"], name: "index_trucking_rates_on_trucking_scope_id"
  end

  create_table "trucking_scopes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "load_type"
    t.string "cargo_class"
    t.string "carriage"
    t.uuid "courier_id"
    t.string "truck_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_truckings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "hub_id"
    t.uuid "location_id"
    t.uuid "rate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "load_meterage"
    t.integer "cbm_ratio"
    t.string "modifier"
    t.integer "tenant_id"
    t.jsonb "rates"
    t.jsonb "fees"
    t.string "identifier_modifier"
    t.string "load_type"
    t.string "cargo_class"
    t.string "carriage"
    t.uuid "courier_id"
    t.string "truck_type"
    t.integer "user_id"
    t.uuid "parent_id"
    t.index ["hub_id"], name: "index_trucking_truckings_on_hub_id"
    t.index ["location_id"], name: "index_trucking_truckings_on_location_id"
    t.index ["rate_id", "location_id", "hub_id"], name: "trucking_foreign_keys", unique: true
  end

  create_table "trucking_type_availabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "load_type"
    t.string "carriage"
    t.string "truck_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "query_method"
  end

  create_table "user_addresses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "address_id"
    t.string "category"
    t.boolean "primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_user_addresses_on_deleted_at"
  end

  create_table "user_managers", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "user_id"
    t.string "section"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", comment: "FILTER WITH users.email NOT LIKE '%@itsmycargo.com' AND users.email NOT LIKE '%demo%@%'", force: :cascade do |t|
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
    t.string "email", comment: "MASKED WITH EmailAddress"
    t.integer "tenant_id"
    t.string "company_name"
    t.string "first_name", comment: "MASKED WITH FirstName"
    t.string "last_name", comment: "MASKED WITH LastName"
    t.string "phone", comment: "MASKED WITH Phone"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id"
    t.boolean "guest", default: false
    t.string "currency", default: "EUR"
    t.string "vat_number"
    t.boolean "allow_password_change", default: false, null: false
    t.jsonb "optin_status", default: {}
    t.integer "optin_status_id"
    t.string "external_id"
    t.integer "agency_id"
    t.boolean "internal", default: false
    t.datetime "deleted_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "users_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "google_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "name"
    t.string "mode_of_transport"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", comment: "IGNORE DATA", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "remarks", "tenants"
  add_foreign_key "shipments", "transport_categories"
  add_foreign_key "tenant_cargo_item_types", "cargo_item_types"
  add_foreign_key "tenant_cargo_item_types", "tenants"
  add_foreign_key "users", "roles"
end
