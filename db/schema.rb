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

ActiveRecord::Schema.define(version: 2020_05_26_101919) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "tablefunc"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type_20200211"
    t.bigint "record_id_20200211"
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
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
    t.index ["tenant_id"], name: "index_addons_on_tenant_id"
  end

  create_table "address_book_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "sandbox_id"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.geometry "point", limit: {:srid=>0, :type=>"geometry"}
    t.string "geocoded_address"
    t.string "street"
    t.string "street_number"
    t.string "postal_code"
    t.string "city"
    t.string "province"
    t.string "premise"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tms_id"
    t.index ["sandbox_id"], name: "index_address_book_contacts_on_sandbox_id"
    t.index ["user_id"], name: "index_address_book_contacts_on_user_id"
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_addresses_on_sandbox_id"
  end

  create_table "agencies", force: :cascade do |t|
    t.string "name"
    t.integer "tenant_id"
    t.integer "agency_manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_agencies_on_tenant_id"
  end

  create_table "aggregated_cargos", force: :cascade do |t|
    t.decimal "weight"
    t.decimal "volume"
    t.decimal "chargeable_weight"
    t.integer "shipment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_aggregated_cargos_on_sandbox_id"
  end

  create_table "alternative_names", force: :cascade do |t|
    t.string "model"
    t.string "model_id"
    t.string "name"
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cargo_cargos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "quotation_id"
    t.integer "total_goods_value_cents", default: 0, null: false
    t.string "total_goods_value_currency", null: false
    t.index ["quotation_id"], name: "index_cargo_cargos_on_quotation_id"
    t.index ["tenant_id"], name: "index_cargo_cargos_on_tenant_id"
  end

  create_table "cargo_item_types", force: :cascade do |t|
    t.decimal "dimension_x"
    t.decimal "dimension_y"
    t.string "description"
    t.string "area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.decimal "width"
    t.decimal "length"
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
    t.uuid "sandbox_id"
    t.string "contents"
    t.decimal "width"
    t.decimal "length"
    t.decimal "height"
    t.index ["sandbox_id"], name: "index_cargo_items_on_sandbox_id"
  end

  create_table "cargo_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.integer "quantity", default: 0
    t.bigint "cargo_class", default: 0
    t.bigint "cargo_type", default: 0
    t.boolean "stackable", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight_value", precision: 100, scale: 3, default: "0.0"
    t.decimal "width_value", precision: 100, scale: 4, default: "0.0"
    t.decimal "length_value", precision: 100, scale: 4, default: "0.0"
    t.decimal "height_value", precision: 100, scale: 4, default: "0.0"
    t.decimal "volume_value", precision: 100, scale: 6, default: "0.0"
    t.string "volume_unit", default: "m3"
    t.string "weight_unit", default: "kg"
    t.string "width_unit", default: "m"
    t.string "length_unit", default: "m"
    t.string "height_unit", default: "m"
    t.uuid "cargo_id"
    t.integer "dangerous_goods", default: 0
    t.integer "goods_value_cents", default: 0, null: false
    t.string "goods_value_currency", null: false
    t.index ["cargo_class"], name: "index_cargo_units_on_cargo_class"
    t.index ["cargo_id"], name: "index_cargo_units_on_cargo_id"
    t.index ["cargo_type"], name: "index_cargo_units_on_cargo_type"
    t.index ["tenant_id"], name: "index_cargo_units_on_tenant_id"
  end

  create_table "carriers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.string "code"
    t.index ["sandbox_id"], name: "index_carriers_on_sandbox_id"
  end

  create_table "charge_breakdowns", force: :cascade do |t|
    t.integer "shipment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trip_id"
    t.uuid "sandbox_id"
    t.datetime "valid_until"
    t.uuid "tender_id"
    t.index ["sandbox_id"], name: "index_charge_breakdowns_on_sandbox_id"
  end

  create_table "charge_categories", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "cargo_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_id"
    t.uuid "sandbox_id"
    t.index ["cargo_unit_id"], name: "index_charge_categories_on_cargo_unit_id"
    t.index ["code"], name: "index_charge_categories_on_code"
    t.index ["sandbox_id"], name: "index_charge_categories_on_sandbox_id"
    t.index ["tenant_id"], name: "index_charge_categories_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.index ["charge_category_id"], name: "index_charges_on_charge_category_id"
    t.index ["children_charge_category_id"], name: "index_charges_on_children_charge_category_id"
    t.index ["sandbox_id"], name: "index_charges_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_contacts_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.string "contents"
    t.index ["sandbox_id"], name: "index_containers_on_sandbox_id"
  end

  create_table "contents_20200504", force: :cascade do |t|
    t.jsonb "text", default: {}
    t.string "component"
    t.string "section"
    t.integer "index"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_contents_20200504_on_tenant_id"
  end

  create_table "conversations_20200114", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "tenant_id"
    t.integer "user_id"
    t.integer "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_updated"
    t.integer "unreads"
    t.index ["tenant_id"], name: "index_conversations_20200114_on_tenant_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "couriers_20200504", force: :cascade do |t|
    t.string "name"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_couriers_20200504_on_sandbox_id"
    t.index ["tenant_id"], name: "index_couriers_20200504_on_tenant_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.jsonb "today"
    t.jsonb "yesterday"
    t.string "base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_id"
    t.index ["tenant_id"], name: "index_currencies_on_tenant_id"
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
    t.index ["tenant_id"], name: "index_customs_fees_on_tenant_id"
  end

  create_table "documents_20200504", force: :cascade do |t|
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_documents_20200504_on_sandbox_id"
    t.index ["tenant_id"], name: "index_documents_20200504_on_tenant_id"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.decimal "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from"], name: "index_exchange_rates_on_from"
    t.index ["to"], name: "index_exchange_rates_on_to"
  end

  create_table "geometries_20200504", force: :cascade do |t|
    t.string "name_1"
    t.string "name_2"
    t.string "name_3"
    t.string "name_4"
    t.geometry "data", limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hub_truck_type_availabilities_20200504", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "truck_type_availability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hub_truckings_20200504", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "trucking_destination_id"
    t.integer "trucking_pricing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hub_id"], name: "index_hub_truckings_20200504_on_hub_id"
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
    t.uuid "sandbox_id"
    t.boolean "free_out", default: false
    t.geometry "point", limit: {:srid=>4326, :type=>"geometry"}
    t.index ["point"], name: "index_hubs_on_point", using: :gist
    t.index ["sandbox_id"], name: "index_hubs_on_sandbox_id"
    t.index ["tenant_id"], name: "index_hubs_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.string "transshipment"
    t.bigint "origin_hub_id"
    t.bigint "destination_hub_id"
    t.index ["destination_hub_id"], name: "index_itineraries_on_destination_hub_id"
    t.index ["mode_of_transport"], name: "index_itineraries_on_mode_of_transport"
    t.index ["name"], name: "index_itineraries_on_name"
    t.index ["origin_hub_id"], name: "index_itineraries_on_origin_hub_id"
    t.index ["sandbox_id"], name: "index_itineraries_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_layovers_on_sandbox_id"
    t.index ["stop_id"], name: "index_layovers_on_stop_id"
  end

  create_table "ledger_delta", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "amount_cents", default: 0, null: false
    t.string "amount_currency", null: false
    t.uuid "fee_id"
    t.integer "rate_basis", default: 0, null: false
    t.numrange "kg_range"
    t.numrange "stowage_range"
    t.numrange "km_range"
    t.numrange "cbm_range"
    t.numrange "wm_range"
    t.numrange "unit_range"
    t.bigint "min_amount_cents", default: 0, null: false
    t.string "min_amount_currency", null: false
    t.bigint "max_amount_cents", default: 0, null: false
    t.string "max_amount_currency", null: false
    t.decimal "wm_ratio", default: "1000.0"
    t.integer "operator", default: 0, null: false
    t.integer "level", default: 0, null: false
    t.string "target_type"
    t.uuid "target_id"
    t.daterange "validity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cbm_range"], name: "index_ledger_delta_on_cbm_range", using: :gist
    t.index ["fee_id"], name: "index_ledger_delta_on_fee_id"
    t.index ["kg_range"], name: "index_ledger_delta_on_kg_range", using: :gist
    t.index ["km_range"], name: "index_ledger_delta_on_km_range", using: :gist
    t.index ["stowage_range"], name: "index_ledger_delta_on_stowage_range", using: :gist
    t.index ["target_type", "target_id"], name: "ledger_delta_target_index"
    t.index ["unit_range"], name: "index_ledger_delta_on_unit_range", using: :gist
    t.index ["validity"], name: "index_ledger_delta_on_validity", using: :gist
    t.index ["wm_range"], name: "index_ledger_delta_on_wm_range", using: :gist
  end

  create_table "ledger_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "cargo_class", default: 0
    t.bigint "cargo_type", default: 0
    t.integer "category", default: 0
    t.string "code"
    t.uuid "rate_id"
    t.integer "action", default: 0
    t.decimal "base", default: "0.000001"
    t.integer "order", default: 0
    t.integer "applicable", default: 0
    t.decimal "load_meterage_limit", default: "0.0"
    t.integer "load_meterage_type", default: 0
    t.integer "load_meterage_logic", default: 0
    t.decimal "load_meterage_ratio", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_class"], name: "index_ledger_fees_on_cargo_class"
    t.index ["cargo_type"], name: "index_ledger_fees_on_cargo_type"
    t.index ["category"], name: "index_ledger_fees_on_category"
    t.index ["rate_id"], name: "index_ledger_fees_on_rate_id"
  end

  create_table "ledger_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "target_type"
    t.uuid "target_id"
    t.uuid "location_id"
    t.uuid "terminal_id"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_ledger_rates_on_location_id"
    t.index ["target_type", "target_id"], name: "ledger_rate_target_index"
    t.index ["tenant_id"], name: "index_ledger_rates_on_tenant_id"
    t.index ["terminal_id"], name: "index_ledger_rates_on_terminal_id"
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

  create_table "legacy_contents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "component"
    t.integer "index"
    t.string "section"
    t.integer "tenant_id"
    t.jsonb "text", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component"], name: "index_legacy_contents_on_component"
    t.index ["tenant_id"], name: "index_legacy_contents_on_tenant_id"
  end

  create_table "legacy_countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_currencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "approval_details"
    t.string "approved"
    t.string "doc_type"
    t.integer "quotation_id"
    t.uuid "sandbox_id"
    t.integer "shipment_id"
    t.integer "tenant_id"
    t.string "text"
    t.string "url"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quotation_id"], name: "index_legacy_files_on_quotation_id"
    t.index ["sandbox_id"], name: "index_legacy_files_on_sandbox_id"
    t.index ["shipment_id"], name: "index_legacy_files_on_shipment_id"
    t.index ["tenant_id"], name: "index_legacy_files_on_tenant_id"
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

  create_table "legacy_transit_times", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "tenant_vehicle_id"
    t.integer "itinerary_id"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itinerary_id"], name: "index_legacy_transit_times_on_itinerary_id"
    t.index ["tenant_vehicle_id"], name: "index_legacy_transit_times_on_tenant_vehicle_id"
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
    t.uuid "sandbox_id"
    t.uuid "group_id"
    t.boolean "internal", default: false
    t.jsonb "metadata", default: {}
    t.daterange "validity"
    t.index ["direction"], name: "index_local_charges_on_direction"
    t.index ["group_id"], name: "index_local_charges_on_group_id"
    t.index ["hub_id"], name: "index_local_charges_on_hub_id"
    t.index ["load_type"], name: "index_local_charges_on_load_type"
    t.index ["sandbox_id"], name: "index_local_charges_on_sandbox_id"
    t.index ["tenant_id"], name: "index_local_charges_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_local_charges_on_tenant_vehicle_id"
    t.index ["uuid"], name: "index_local_charges_on_uuid", unique: true
    t.index ["validity"], name: "index_local_charges_on_validity", using: :gist
  end

  create_table "locations_20200504", force: :cascade do |t|
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_map_data_on_sandbox_id"
    t.index ["tenant_id"], name: "index_map_data_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.bigint "carrier_id"
    t.bigint "tenant_vehicle_id"
    t.string "cargo_class"
    t.bigint "itinerary_id"
    t.decimal "width"
    t.decimal "length"
    t.decimal "height"
    t.index ["cargo_class"], name: "index_max_dimensions_bundles_on_cargo_class"
    t.index ["carrier_id"], name: "index_max_dimensions_bundles_on_carrier_id"
    t.index ["itinerary_id"], name: "index_max_dimensions_bundles_on_itinerary_id"
    t.index ["mode_of_transport"], name: "index_max_dimensions_bundles_on_mode_of_transport"
    t.index ["sandbox_id"], name: "index_max_dimensions_bundles_on_sandbox_id"
    t.index ["tenant_id"], name: "index_max_dimensions_bundles_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_max_dimensions_bundles_on_tenant_vehicle_id"
  end

  create_table "messages_20200114", force: :cascade do |t|
    t.string "title"
    t.string "message"
    t.integer "conversation_id"
    t.boolean "read"
    t.datetime "read_at"
    t.integer "sender_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mot_scopes_20200504", force: :cascade do |t|
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
    t.uuid "sandbox_id"
    t.string "locode"
    t.index ["sandbox_id"], name: "index_nexuses_on_sandbox_id"
    t.index ["tenant_id"], name: "index_nexuses_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.string "target_type"
    t.integer "target_id"
    t.uuid "pricings_pricing_id"
    t.integer "tenant_id"
    t.boolean "contains_html"
    t.boolean "transshipment", default: false, null: false
    t.boolean "remarks", default: false, null: false
    t.index ["pricings_pricing_id"], name: "index_notes_on_pricings_pricing_id"
    t.index ["remarks"], name: "index_notes_on_remarks"
    t.index ["sandbox_id"], name: "index_notes_on_sandbox_id"
    t.index ["target_type", "target_id"], name: "index_notes_on_target_type_and_target_id"
    t.index ["transshipment"], name: "index_notes_on_transshipment"
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

  create_table "optin_statuses_20200504", force: :cascade do |t|
    t.boolean "cookies"
    t.boolean "tenant"
    t.boolean "itsmycargo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_optin_statuses_20200504_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_prices_on_sandbox_id"
  end

  create_table "pricing_details_20200504", force: :cascade do |t|
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
    t.uuid "sandbox_id"
    t.index ["currency_id"], name: "index_pricing_details_20200504_on_currency_id"
    t.index ["sandbox_id"], name: "index_pricing_details_20200504_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricing_details_20200504_on_tenant_id"
  end

  create_table "pricing_exceptions_20200504", force: :cascade do |t|
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.bigint "pricing_id"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pricing_id"], name: "index_pricing_exceptions_20200504_on_pricing_id"
    t.index ["tenant_id"], name: "index_pricing_exceptions_20200504_on_tenant_id"
  end

  create_table "pricing_requests_20200504", force: :cascade do |t|
    t.integer "pricing_id"
    t.integer "user_id"
    t.integer "tenant_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pricing_id"], name: "index_pricing_requests_20200504_on_pricing_id"
    t.index ["tenant_id"], name: "index_pricing_requests_20200504_on_tenant_id"
    t.index ["user_id"], name: "index_pricing_requests_20200504_on_user_id"
  end

  create_table "pricings_20200504", force: :cascade do |t|
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
    t.uuid "sandbox_id"
    t.boolean "internal", default: false
    t.daterange "validity"
    t.index ["itinerary_id"], name: "index_pricings_20200504_on_itinerary_id"
    t.index ["sandbox_id"], name: "index_pricings_20200504_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_20200504_on_tenant_id"
    t.index ["transport_category_id"], name: "index_pricings_20200504_on_transport_category_id"
    t.index ["user_id"], name: "index_pricings_20200504_on_user_id"
    t.index ["uuid"], name: "index_pricings_20200504_on_uuid", unique: true
    t.index ["validity"], name: "legacy_pricings_validity_index", using: :gist
  end

  create_table "pricings_breakdowns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "metadatum_id", null: false
    t.string "pricing_id"
    t.string "cargo_class"
    t.uuid "margin_id"
    t.jsonb "data"
    t.string "target_type"
    t.uuid "target_id"
    t.string "cargo_unit_type"
    t.bigint "cargo_unit_id"
    t.integer "charge_category_id"
    t.integer "charge_id"
    t.jsonb "rate_origin", default: {}
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_type"
    t.uuid "source_id"
    t.index ["cargo_unit_type", "cargo_unit_id"], name: "index_pricings_breakdowns_on_cargo_unit_type_and_cargo_unit_id"
    t.index ["charge_category_id"], name: "index_pricings_breakdowns_on_charge_category_id"
    t.index ["charge_id"], name: "index_pricings_breakdowns_on_charge_id"
    t.index ["margin_id"], name: "index_pricings_breakdowns_on_margin_id"
    t.index ["metadatum_id"], name: "index_pricings_breakdowns_on_metadatum_id"
    t.index ["source_type", "source_id"], name: "index_pricings_breakdowns_on_source_type_and_source_id"
    t.index ["target_type", "target_id"], name: "index_pricings_breakdowns_on_target_type_and_target_id"
  end

  create_table "pricings_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.uuid "margin_id"
    t.decimal "value"
    t.string "operator"
    t.integer "charge_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["charge_category_id"], name: "index_pricings_details_on_charge_category_id"
    t.index ["margin_id"], name: "index_pricings_details_on_margin_id"
    t.index ["sandbox_id"], name: "index_pricings_details_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.jsonb "metadata", default: {}
    t.index ["pricing_id"], name: "index_pricings_fees_on_pricing_id"
    t.index ["sandbox_id"], name: "index_pricings_fees_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_fees_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.daterange "validity"
    t.index ["applicable_type", "applicable_id"], name: "index_pricings_margins_on_applicable_type_and_applicable_id"
    t.index ["application_order"], name: "index_pricings_margins_on_application_order"
    t.index ["cargo_class"], name: "index_pricings_margins_on_cargo_class"
    t.index ["destination_hub_id"], name: "index_pricings_margins_on_destination_hub_id"
    t.index ["effective_date"], name: "index_pricings_margins_on_effective_date"
    t.index ["expiration_date"], name: "index_pricings_margins_on_expiration_date"
    t.index ["itinerary_id"], name: "index_pricings_margins_on_itinerary_id"
    t.index ["margin_type"], name: "index_pricings_margins_on_margin_type"
    t.index ["origin_hub_id"], name: "index_pricings_margins_on_origin_hub_id"
    t.index ["pricing_id"], name: "index_pricings_margins_on_pricing_id"
    t.index ["sandbox_id"], name: "index_pricings_margins_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_margins_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_pricings_margins_on_tenant_vehicle_id"
  end

  create_table "pricings_metadata", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "pricing_id"
    t.integer "charge_breakdown_id"
    t.integer "cargo_unit_id"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charge_breakdown_id"], name: "index_pricings_metadata_on_charge_breakdown_id"
    t.index ["tenant_id"], name: "index_pricings_metadata_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.boolean "internal", default: false
    t.uuid "group_id"
    t.daterange "validity"
    t.string "transshipment"
    t.index ["cargo_class"], name: "index_pricings_pricings_on_cargo_class"
    t.index ["group_id"], name: "index_pricings_pricings_on_group_id"
    t.index ["itinerary_id"], name: "index_pricings_pricings_on_itinerary_id"
    t.index ["load_type"], name: "index_pricings_pricings_on_load_type"
    t.index ["sandbox_id"], name: "index_pricings_pricings_on_sandbox_id"
    t.index ["tenant_id"], name: "index_pricings_pricings_on_tenant_id"
    t.index ["tenant_vehicle_id"], name: "index_pricings_pricings_on_tenant_vehicle_id"
    t.index ["user_id"], name: "index_pricings_pricings_on_user_id"
    t.index ["validity"], name: "index_pricings_pricings_on_validity", using: :gist
  end

  create_table "pricings_rate_bases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_code"
    t.string "internal_code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["external_code"], name: "index_pricings_rate_bases_on_external_code"
    t.index ["sandbox_id"], name: "index_pricings_rate_bases_on_sandbox_id"
  end

  create_table "profiles_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "company_name"
    t.string "phone"
    t.uuid "user_id"
    t.index ["user_id"], name: "index_profiles_profiles_on_user_id"
  end

  create_table "quotations", force: :cascade do |t|
    t.string "target_email"
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "original_shipment_id"
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_quotations_on_sandbox_id"
  end

  create_table "quotations_line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tender_id"
    t.bigint "charge_category_id"
    t.integer "amount_cents"
    t.string "amount_currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "section"
    t.string "cargo_type"
    t.integer "cargo_id"
    t.integer "original_amount_cents"
    t.string "original_amount_currency"
    t.index ["cargo_type", "cargo_id"], name: "index_quotations_line_items_on_cargo_type_and_cargo_id"
    t.index ["charge_category_id"], name: "index_quotations_line_items_on_charge_category_id"
    t.index ["tender_id"], name: "index_quotations_line_items_on_tender_id"
  end

  create_table "quotations_quotations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id"
    t.uuid "tenant_id"
    t.integer "origin_nexus_id"
    t.integer "destination_nexus_id"
    t.datetime "selected_date"
    t.bigint "sandbox_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pickup_address_id"
    t.integer "delivery_address_id"
    t.uuid "tenants_user_id"
    t.integer "legacy_shipment_id"
    t.index ["destination_nexus_id"], name: "index_quotations_quotations_on_destination_nexus_id"
    t.index ["origin_nexus_id"], name: "index_quotations_quotations_on_origin_nexus_id"
    t.index ["sandbox_id"], name: "index_quotations_quotations_on_sandbox_id"
    t.index ["tenant_id"], name: "index_quotations_quotations_on_tenant_id"
    t.index ["user_id"], name: "index_quotations_quotations_on_user_id"
  end

  create_table "quotations_tenders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "tenant_vehicle_id"
    t.integer "origin_hub_id"
    t.integer "destination_hub_id"
    t.string "carrier_name"
    t.string "name"
    t.string "load_type"
    t.integer "amount_cents"
    t.string "amount_currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "quotation_id"
    t.integer "itinerary_id"
    t.string "transshipment"
    t.integer "original_amount_cents"
    t.string "original_amount_currency"
    t.index ["destination_hub_id"], name: "index_quotations_tenders_on_destination_hub_id"
    t.index ["origin_hub_id"], name: "index_quotations_tenders_on_origin_hub_id"
    t.index ["quotation_id"], name: "index_quotations_tenders_on_quotation_id"
    t.index ["tenant_vehicle_id"], name: "index_quotations_tenders_on_tenant_vehicle_id"
  end

  create_table "rate_bases", force: :cascade do |t|
    t.string "external_code"
    t.string "internal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rates_cargos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "section_id"
    t.integer "cargo_class", default: 0
    t.integer "cargo_type", default: 0
    t.integer "category", default: 0
    t.string "code"
    t.integer "valid_at"
    t.integer "operator"
    t.integer "applicable_to", default: 0
    t.decimal "cbm_ratio"
    t.integer "order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_class"], name: "index_rates_cargos_on_cargo_class"
    t.index ["cargo_type"], name: "index_rates_cargos_on_cargo_type"
    t.index ["category"], name: "index_rates_cargos_on_category"
    t.index ["section_id"], name: "index_rates_cargos_on_section_id"
  end

  create_table "rates_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cargo_id"
    t.bigint "amount_cents", default: 0, null: false
    t.string "amount_currency", null: false
    t.integer "rate_basis", default: 0, null: false
    t.numrange "kg_range"
    t.numrange "stowage_range"
    t.numrange "km_range"
    t.numrange "cbm_range"
    t.numrange "wm_range"
    t.numrange "unit_range"
    t.bigint "min_amount_cents", default: 0, null: false
    t.string "min_amount_currency", null: false
    t.bigint "max_amount_cents", default: 0, null: false
    t.string "max_amount_currency", null: false
    t.decimal "cbm_ratio", default: "1000.0"
    t.integer "operator", default: 0, null: false
    t.integer "level", default: 0, null: false
    t.jsonb "rule"
    t.daterange "validity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "percentage"
    t.index ["cargo_id"], name: "index_rates_fees_on_cargo_id"
  end

  create_table "rates_sections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "target_type"
    t.uuid "target_id"
    t.uuid "tenant_id"
    t.uuid "location_id"
    t.uuid "terminal_id"
    t.bigint "carrier_id"
    t.integer "mode_of_transport"
    t.integer "ldm_threshold_applicable"
    t.integer "ldm_measurement"
    t.decimal "ldm_ratio", default: "0.0"
    t.decimal "ldm_threshold", default: "0.0"
    t.boolean "disabled"
    t.decimal "ldm_area_divisor"
    t.decimal "truck_height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_rates_sections_on_carrier_id"
    t.index ["location_id"], name: "index_rates_sections_on_location_id"
    t.index ["target_type", "target_id"], name: "index_rates_sections_on_target_type_and_target_id"
    t.index ["tenant_id"], name: "index_rates_sections_on_tenant_id"
    t.index ["terminal_id"], name: "index_rates_sections_on_terminal_id"
  end

  create_table "remarks", force: :cascade do |t|
    t.bigint "tenant_id"
    t.string "category"
    t.string "subcategory"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_remarks_on_sandbox_id"
    t.index ["tenant_id"], name: "index_remarks_on_tenant_id"
  end

  create_table "rms_data_books", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "sheet_type"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata", default: {}
    t.string "target_type"
    t.uuid "target_id"
    t.integer "book_type", default: 0, null: false
    t.index ["sheet_type"], name: "index_rms_data_books_on_sheet_type"
    t.index ["target_type", "target_id"], name: "index_rms_data_books_on_target_type_and_target_id"
    t.index ["tenant_id"], name: "index_rms_data_books_on_tenant_id"
  end

  create_table "rms_data_cells", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.integer "row"
    t.integer "column"
    t.string "value"
    t.uuid "sheet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["column"], name: "index_rms_data_cells_on_column"
    t.index ["row"], name: "index_rms_data_cells_on_row"
    t.index ["sheet_id"], name: "index_rms_data_cells_on_sheet_id"
    t.index ["tenant_id"], name: "index_rms_data_cells_on_tenant_id"
  end

  create_table "rms_data_sheets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "sheet_index"
    t.uuid "tenant_id"
    t.uuid "book_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.jsonb "metadata", default: {}
    t.index ["book_id"], name: "index_rms_data_sheets_on_book_id"
    t.index ["sheet_index"], name: "index_rms_data_sheets_on_sheet_index"
    t.index ["tenant_id"], name: "index_rms_data_sheets_on_tenant_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routing_carriers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "abbreviated_name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "code", "abbreviated_name"], name: "routing_carriers_index", unique: true
  end

  create_table "routing_line_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "carrier_id"
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id", "name"], name: "line_service_unique_index", unique: true
    t.index ["carrier_id"], name: "index_routing_line_services_on_carrier_id"
  end

  create_table "routing_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "locode"
    t.geometry "center", limit: {:srid=>0, :type=>"geometry"}
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.string "name"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bounds"], name: "index_routing_locations_on_bounds", using: :gist
    t.index ["center"], name: "index_routing_locations_on_center"
    t.index ["locode"], name: "index_routing_locations_on_locode"
  end

  create_table "routing_route_line_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "route_id"
    t.uuid "line_service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transit_time"
    t.index ["route_id", "line_service_id"], name: "route_line_service_index", unique: true
  end

  create_table "routing_routes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "origin_id"
    t.uuid "destination_id"
    t.integer "allowed_cargo", default: 0, null: false
    t.integer "mode_of_transport", default: 0, null: false
    t.decimal "price_factor"
    t.decimal "time_factor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "origin_terminal_id"
    t.uuid "destination_terminal_id"
    t.index ["origin_id", "destination_id", "origin_terminal_id", "destination_terminal_id", "mode_of_transport"], name: "routing_routes_index", unique: true
  end

  create_table "routing_terminals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "location_id"
    t.geometry "center", limit: {:srid=>0, :type=>"geometry"}
    t.string "terminal_code"
    t.boolean "default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_of_transport", default: 0
    t.index ["center"], name: "index_routing_terminals_on_center"
  end

  create_table "routing_transit_times_20191213111544", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "route_line_service_id"
    t.decimal "days"
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

  create_table "sequential_sequences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "value", default: 0
    t.integer "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipment_contacts", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "contact_id"
    t.string "contact_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_shipment_contacts_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.uuid "tender_id"
    t.datetime "deleted_at"
    t.index ["sandbox_id"], name: "index_shipments_on_sandbox_id", where: "(deleted_at IS NULL)"
    t.index ["tenant_id"], name: "index_shipments_on_tenant_id", where: "(deleted_at IS NULL)"
    t.index ["tender_id"], name: "index_shipments_on_tender_id"
  end

  create_table "shipments_cargos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sandbox_id"
    t.uuid "shipment_id"
    t.uuid "tenant_id"
    t.integer "total_goods_value_cents", default: 0, null: false
    t.string "total_goods_value_currency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_shipments_cargos_on_sandbox_id"
    t.index ["shipment_id"], name: "index_shipments_cargos_on_shipment_id"
    t.index ["tenant_id"], name: "index_shipments_cargos_on_tenant_id"
  end

  create_table "shipments_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shipment_id", null: false
    t.uuid "sandbox_id"
    t.integer "contact_type"
    t.float "latitude"
    t.float "longitude"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.string "geocoded_address"
    t.string "street"
    t.string "street_number"
    t.string "post_code"
    t.string "city"
    t.string "province"
    t.string "premise"
    t.string "country_code"
    t.string "country_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_shipments_contacts_on_sandbox_id"
    t.index ["shipment_id"], name: "index_shipments_contacts_on_shipment_id"
  end

  create_table "shipments_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "attachable_type", null: false
    t.uuid "attachable_id", null: false
    t.uuid "sandbox_id"
    t.integer "doc_type"
    t.string "file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_shipments_documents_on_attachable_type_and_attachable_id"
    t.index ["sandbox_id"], name: "index_shipments_documents_on_sandbox_id"
  end

  create_table "shipments_invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sandbox_id"
    t.uuid "shipment_id", null: false
    t.bigint "invoice_number"
    t.integer "amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_shipments_invoices_on_sandbox_id"
    t.index ["shipment_id"], name: "index_shipments_invoices_on_shipment_id"
  end

  create_table "shipments_line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", null: false
    t.string "fee_code"
    t.uuid "cargo_id"
    t.uuid "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_id"], name: "index_shipments_line_items_on_cargo_id"
    t.index ["invoice_id"], name: "index_shipments_line_items_on_invoice_id"
  end

  create_table "shipments_shipment_request_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shipment_request_id", null: false
    t.uuid "contact_id", null: false
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_shipment_request_contacts_on_contact_id"
    t.index ["shipment_request_id"], name: "index_shipment_request_contacts_on_shipment_request_id"
  end

  create_table "shipments_shipment_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status"
    t.string "cargo_notes"
    t.string "notes"
    t.string "incoterm_text"
    t.string "eori"
    t.string "ref_number", null: false
    t.datetime "submitted_at"
    t.datetime "eta"
    t.datetime "etd"
    t.uuid "sandbox_id"
    t.uuid "user_id", null: false
    t.uuid "tenant_id", null: false
    t.uuid "tender_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sandbox_id"], name: "index_shipments_shipment_requests_on_sandbox_id"
    t.index ["tenant_id"], name: "index_shipments_shipment_requests_on_tenant_id"
    t.index ["tender_id"], name: "index_shipments_shipment_requests_on_tender_id"
    t.index ["user_id"], name: "index_shipments_shipment_requests_on_user_id"
  end

  create_table "shipments_shipments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shipment_request_id"
    t.uuid "sandbox_id"
    t.uuid "user_id", null: false
    t.uuid "origin_id", null: false
    t.uuid "destination_id", null: false
    t.uuid "tenant_id", null: false
    t.string "status"
    t.string "notes"
    t.string "incoterm_text"
    t.string "eori"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_shipments_shipments_on_destination_id"
    t.index ["origin_id"], name: "index_shipments_shipments_on_origin_id"
    t.index ["sandbox_id"], name: "index_shipments_shipments_on_sandbox_id"
    t.index ["shipment_request_id"], name: "index_shipments_shipments_on_shipment_request_id"
    t.index ["tenant_id"], name: "index_shipments_shipments_on_tenant_id"
    t.index ["user_id"], name: "index_shipments_shipments_on_user_id"
  end

  create_table "shipments_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sandbox_id"
    t.uuid "cargo_id", null: false
    t.integer "goods_value_cents", default: 0, null: false
    t.string "goods_value_currency", null: false
    t.integer "quantity", null: false
    t.bigint "cargo_class"
    t.bigint "cargo_type"
    t.boolean "stackable"
    t.integer "dangerous_goods", default: 0
    t.decimal "weight_value", precision: 100, scale: 3
    t.string "weight_unit", default: "kg"
    t.decimal "width_value", precision: 100, scale: 4
    t.string "width_unit", default: "m"
    t.decimal "length_value", precision: 100, scale: 4
    t.string "length_unit", default: "m"
    t.decimal "height_value", precision: 100, scale: 4
    t.string "height_unit", default: "m"
    t.decimal "volume_value", precision: 100, scale: 6
    t.string "volume_unit", default: "m3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_id"], name: "index_shipments_units_on_cargo_id"
    t.index ["sandbox_id"], name: "index_shipments_units_on_sandbox_id"
  end

  create_table "stops", force: :cascade do |t|
    t.integer "hub_id"
    t.integer "itinerary_id"
    t.integer "index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["hub_id"], name: "index_stops_on_hub_id"
    t.index ["itinerary_id"], name: "index_stops_on_itinerary_id"
    t.index ["sandbox_id"], name: "index_stops_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.index ["cargo_item_type_id"], name: "index_tenant_cargo_item_types_on_cargo_item_type_id"
    t.index ["sandbox_id"], name: "index_tenant_cargo_item_types_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenant_cargo_item_types_on_tenant_id"
  end

  create_table "tenant_incoterms", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "incoterm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenant_incoterms_on_tenant_id"
  end

  create_table "tenant_routing_connections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inbound_id"
    t.uuid "outbound_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "tenant_id"
    t.integer "mode_of_transport", default: 0
    t.uuid "line_service_id"
    t.index ["inbound_id"], name: "index_tenant_routing_connections_on_inbound_id"
    t.index ["outbound_id"], name: "index_tenant_routing_connections_on_outbound_id"
    t.index ["tenant_id"], name: "index_tenant_routing_connections_on_tenant_id"
  end

  create_table "tenant_routing_routes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.uuid "route_id"
    t.integer "mode_of_transport", default: 0
    t.integer "price_factor"
    t.integer "time_factor"
    t.uuid "line_service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_service_id"], name: "index_tenant_routing_routes_on_line_service_id"
    t.index ["mode_of_transport"], name: "index_tenant_routing_routes_on_mode_of_transport"
    t.index ["tenant_id"], name: "index_tenant_routing_routes_on_tenant_id"
  end

  create_table "tenant_routing_visibilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "target_type"
    t.uuid "target_id"
    t.uuid "connection_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "visibility_connection_index"
    t.index ["target_type", "target_id"], name: "visibility_target_index"
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_tenant_vehicles_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenant_vehicles_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.datetime "deleted_at"
    t.index ["sandbox_id"], name: "index_tenants_companies_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenants_companies_on_tenant_id"
  end

  create_table "tenants_domains", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.string "domain"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenants_domains_on_tenant_id"
  end

  create_table "tenants_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_tenants_groups_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenants_groups_on_tenant_id"
  end

  create_table "tenants_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "member_type"
    t.uuid "member_id"
    t.uuid "group_id"
    t.integer "priority", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["member_type", "member_id"], name: "index_tenants_memberships_on_member_type_and_member_id"
    t.index ["sandbox_id"], name: "index_tenants_memberships_on_sandbox_id"
  end

  create_table "tenants_saml_metadata", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "content"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenants_saml_metadata_on_tenant_id"
  end

  create_table "tenants_sandboxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenants_sandboxes_on_tenant_id"
  end

  create_table "tenants_scopes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "target_type"
    t.uuid "target_id"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_tenants_scopes_on_sandbox_id"
    t.index ["target_type", "target_id"], name: "index_tenants_scopes_on_target_type_and_target_id"
  end

  create_table "tenants_tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subdomain"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
  end

  create_table "tenants_themes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.string "primary_color"
    t.string "secondary_color"
    t.string "bright_primary_color"
    t.string "bright_secondary_color"
    t.string "welcome_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenants_themes_on_tenant_id"
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
    t.uuid "sandbox_id"
    t.datetime "deleted_at"
    t.index ["activation_token"], name: "index_tenants_users_on_activation_token"
    t.index ["email", "tenant_id"], name: "index_tenants_users_on_email_and_tenant_id", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_tenants_users_on_last_logout_at_and_last_activity_at"
    t.index ["reset_password_token"], name: "index_tenants_users_on_reset_password_token"
    t.index ["sandbox_id"], name: "index_tenants_users_on_sandbox_id"
    t.index ["tenant_id"], name: "index_tenants_users_on_tenant_id"
    t.index ["unlock_token"], name: "index_tenants_users_on_unlock_token"
  end

  create_table "transport_categories_20200504", force: :cascade do |t|
    t.integer "vehicle_id"
    t.string "mode_of_transport"
    t.string "name"
    t.string "cargo_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "load_type"
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_transport_categories_20200504_on_sandbox_id"
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
    t.uuid "sandbox_id"
    t.index ["closing_date"], name: "index_trips_on_closing_date"
    t.index ["itinerary_id"], name: "index_trips_on_itinerary_id"
    t.index ["sandbox_id"], name: "index_trips_on_sandbox_id"
    t.index ["tenant_vehicle_id"], name: "index_trips_on_tenant_vehicle_id"
  end

  create_table "truck_type_availabilities_20200504", force: :cascade do |t|
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
    t.uuid "sandbox_id"
    t.index ["sandbox_id"], name: "index_trucking_couriers_on_sandbox_id"
    t.index ["tenant_id"], name: "index_trucking_couriers_on_tenant_id"
  end

  create_table "trucking_coverages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "hub_id"
    t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["bounds"], name: "index_trucking_coverages_on_bounds", using: :gist
    t.index ["sandbox_id"], name: "index_trucking_coverages_on_sandbox_id"
  end

  create_table "trucking_destinations_20200504", force: :cascade do |t|
    t.string "zipcode"
    t.string "country_code"
    t.string "city_name"
    t.integer "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.uuid "sandbox_id"
    t.index ["city_name"], name: "index_trucking_destinations_20200504_on_city_name"
    t.index ["country_code"], name: "index_trucking_destinations_20200504_on_country_code"
    t.index ["distance"], name: "index_trucking_destinations_20200504_on_distance"
    t.index ["sandbox_id"], name: "index_trucking_destinations_20200504_on_sandbox_id"
    t.index ["zipcode"], name: "index_trucking_destinations_20200504_on_zipcode"
  end

  create_table "trucking_hub_availabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "hub_id"
    t.uuid "type_availability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["hub_id"], name: "index_trucking_hub_availabilities_on_hub_id"
    t.index ["sandbox_id"], name: "index_trucking_hub_availabilities_on_sandbox_id"
    t.index ["type_availability_id"], name: "index_trucking_hub_availabilities_on_type_availability_id"
  end

  create_table "trucking_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "zipcode"
    t.string "country_code"
    t.string "city_name"
    t.integer "distance"
    t.uuid "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sandbox_id"
    t.index ["city_name"], name: "index_trucking_locations_on_city_name"
    t.index ["country_code"], name: "index_trucking_locations_on_country_code"
    t.index ["distance"], name: "index_trucking_locations_on_distance"
    t.index ["location_id"], name: "index_trucking_locations_on_location_id"
    t.index ["sandbox_id"], name: "index_trucking_locations_on_sandbox_id"
    t.index ["zipcode"], name: "index_trucking_locations_on_zipcode"
  end

  create_table "trucking_pricing_scopes_20200504", force: :cascade do |t|
    t.string "load_type"
    t.string "cargo_class"
    t.string "carriage"
    t.integer "courier_id"
    t.string "truck_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucking_pricings_20200504", force: :cascade do |t|
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
    t.index ["tenant_id"], name: "index_trucking_pricings_20200504_on_tenant_id"
    t.index ["trucking_pricing_scope_id"], name: "index_trucking_pricings_20200504_on_trucking_pricing_scope_id"
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
    t.index ["tenant_id"], name: "index_trucking_rates_on_tenant_id"
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
    t.uuid "group_id"
    t.uuid "sandbox_id"
    t.jsonb "metadata", default: {}
    t.index ["cargo_class"], name: "index_trucking_truckings_on_cargo_class"
    t.index ["carriage"], name: "index_trucking_truckings_on_carriage"
    t.index ["group_id"], name: "index_trucking_truckings_on_group_id"
    t.index ["hub_id"], name: "index_trucking_truckings_on_hub_id"
    t.index ["load_type"], name: "index_trucking_truckings_on_load_type"
    t.index ["location_id"], name: "index_trucking_truckings_on_location_id"
    t.index ["rate_id", "location_id", "hub_id"], name: "trucking_foreign_keys", unique: true
    t.index ["sandbox_id"], name: "index_trucking_truckings_on_sandbox_id"
    t.index ["tenant_id"], name: "index_trucking_truckings_on_tenant_id"
  end

  create_table "trucking_type_availabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "load_type"
    t.string "carriage"
    t.string "truck_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "query_method"
    t.uuid "sandbox_id"
    t.index ["load_type"], name: "index_trucking_type_availabilities_on_load_type"
    t.index ["query_method"], name: "index_trucking_type_availabilities_on_query_method"
    t.index ["sandbox_id"], name: "index_trucking_type_availabilities_on_sandbox_id"
    t.index ["truck_type"], name: "index_trucking_type_availabilities_on_truck_type"
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
    t.string "company_name_20200207"
    t.string "first_name_20200207", comment: "MASKED WITH FirstName"
    t.string "last_name_20200207", comment: "MASKED WITH LastName"
    t.string "phone_20200207", comment: "MASKED WITH Phone"
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
    t.uuid "sandbox_id"
    t.string "company_number"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["sandbox_id"], name: "index_users_on_sandbox_id"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
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

  add_foreign_key "address_book_contacts", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "address_book_contacts", "tenants_users", column: "user_id"
  add_foreign_key "cargo_cargos", "quotations_quotations", column: "quotation_id"
  add_foreign_key "cargo_units", "cargo_cargos", column: "cargo_id"
  add_foreign_key "itineraries", "hubs", column: "destination_hub_id"
  add_foreign_key "itineraries", "hubs", column: "origin_hub_id"
  add_foreign_key "legacy_transit_times", "itineraries"
  add_foreign_key "legacy_transit_times", "tenant_vehicles"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "profiles_profiles", "tenants_users", column: "user_id", on_delete: :cascade
  add_foreign_key "quotations_tenders", "quotations_quotations", column: "quotation_id"
  add_foreign_key "rates_cargos", "rates_sections", column: "section_id"
  add_foreign_key "rates_fees", "rates_cargos", column: "cargo_id"
  add_foreign_key "rates_sections", "carriers"
  add_foreign_key "rates_sections", "routing_locations", column: "location_id"
  add_foreign_key "rates_sections", "routing_terminals", column: "terminal_id"
  add_foreign_key "rates_sections", "tenants_tenants", column: "tenant_id"
  add_foreign_key "remarks", "tenants"
  add_foreign_key "shipments_cargos", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "shipments_cargos", "tenants_tenants", column: "tenant_id"
  add_foreign_key "shipments_contacts", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "shipments_documents", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "shipments_invoices", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "shipments_shipment_request_contacts", "address_book_contacts", column: "contact_id"
  add_foreign_key "shipments_shipment_requests", "quotations_tenders", column: "tender_id"
  add_foreign_key "shipments_shipment_requests", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "shipments_shipment_requests", "tenants_tenants", column: "tenant_id"
  add_foreign_key "shipments_shipment_requests", "tenants_users", column: "user_id"
  add_foreign_key "shipments_shipments", "routing_terminals", column: "destination_id"
  add_foreign_key "shipments_shipments", "routing_terminals", column: "origin_id"
  add_foreign_key "shipments_shipments", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "shipments_shipments", "tenants_tenants", column: "tenant_id"
  add_foreign_key "shipments_shipments", "tenants_users", column: "user_id"
  add_foreign_key "shipments_units", "tenants_sandboxes", column: "sandbox_id"
  add_foreign_key "stops", "itineraries"
  add_foreign_key "tenant_cargo_item_types", "cargo_item_types"
  add_foreign_key "tenant_cargo_item_types", "tenants"
  add_foreign_key "users", "roles"
end
