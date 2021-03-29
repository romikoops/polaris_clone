class BackfillJourneyModelsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  class CountValidationError < StandardError; end

  class RateNotFoundError < StandardError; end

  def expiration
    @expiration ||= 60 * 60 * 24 * 30 # 30 days
  end

  def perform(*_args)
    @failed_quotations = {}.to_json
    create_deleted_point

    quotations = Quotations::Quotation
      .where("error_class != 'ActionController::ParameterMissing' OR error_class IS NULL ")
      .left_joins(pickup_address: :country, delivery_address: :country)

    total quotations.count

    quotations.find_each.with_index do |quotation, index|
      next if Journey::Query.exists?(created_at: quotation.created_at, organization_id: quotation.organization_id)

      quotation_id = quotation.id
      first_tender = quotation.tenders.first

      fall_back_origin, fall_back_destination = first_tender.name.split('-', 2).map(&:strip!)
      ActiveRecord::Base.transaction do
        query_id = insert_query(quotation_id, fall_back_origin, fall_back_destination)
        insert_cargo_units(quotation_id, query_id)
        result_set_id = insert_result_sets(query_id, quotation_id)
        offer_id = insert_offer(query_id, quotation_id)
        insert_error(result_set_id, quotation) if quotation.error_class.present?
        results_ids = insert_results(result_set_id, quotation_id)
        results_ids.each do |result_id|
          line_items = Quotations::LineItem.where(tender_id: result_id)

          original_line_item_set_id = insert_original_line_item_set(result_id, quotation_id)
          edited_line_item_set_id = insert_edited_line_item_set(result_id, quotation_id)
          insert_original_offer_line_item_set(offer_id, original_line_item_set_id, quotation_id)

          #### inserting route points
          origin_nex = first_tender.origin_hub&.nexus

          destination_nex = first_tender.destination_hub&.nexus

          # main freight route points
          origin_route_point = insert_freight_route_point(origin_nex)
          destination_route_point = insert_freight_route_point(destination_nex)

          if line_items.trucking_pre_section.any?
            pickup_route_point = insert_carriage_route_point(quotation.pickup_address)
            pre_carriage_route_section_id = insert_pre_carriage_route_section(result_id, quotation_id, pickup_route_point, origin_route_point)
            insert_line_items(quotation_id, "original_", result_id, pre_carriage_route_section_id, original_line_item_set_id, 1)
            insert_line_items(quotation_id, "", result_id, pre_carriage_route_section_id, edited_line_item_set_id, 1) if edited_line_item_set_id.present?

            insert_cargo_line_items(quotation_id, "original_", result_id, pre_carriage_route_section_id, original_line_item_set_id, 1)
            insert_cargo_line_items(quotation_id, "original_", result_id, pre_carriage_route_section_id, edited_line_item_set_id, 1) if edited_line_item_set_id.present?
          end

          if line_items.export_section.any?
            from = origin_route_point.dup
            to = origin_route_point.dup

            from.save
            to.save
            export_route_section_id = insert_export_route_section(result_id, quotation_id, from, to)
            insert_line_items(quotation_id, "original_", result_id, export_route_section_id, original_line_item_set_id, 2)
            insert_line_items(quotation_id, "", result_id, export_route_section_id, edited_line_item_set_id, 2) if edited_line_item_set_id.present?

            insert_cargo_line_items(quotation_id, "original_", result_id, export_route_section_id, original_line_item_set_id, 2)
            insert_cargo_line_items(quotation_id, "original_", result_id, export_route_section_id, edited_line_item_set_id, 2) if edited_line_item_set_id.present?
          end

          if line_items.cargo_section.any?
            from = origin_route_point.dup
            to = destination_route_point.dup

            from.save
            to.save
            main_freight_route_section_id = insert_main_freight_route_section(result_id, quotation_id, from, to)
            insert_line_items(quotation_id, "original_", result_id, main_freight_route_section_id, original_line_item_set_id, 3)
            insert_line_items(quotation_id, "", result_id, main_freight_route_section_id, edited_line_item_set_id, 3) if edited_line_item_set_id.present?

            insert_cargo_line_items(quotation_id, "original_", result_id, main_freight_route_section_id, original_line_item_set_id, 3)
            insert_cargo_line_items(quotation_id, "original_", result_id, main_freight_route_section_id, edited_line_item_set_id, 3) if edited_line_item_set_id.present?
          end

          if line_items.import_section.any?
            from = destination_route_point.dup
            to = destination_route_point.dup
            from.save
            to.save
            import_route_section_id = insert_import_route_section(result_id, quotation_id, from, to)
            insert_line_items(quotation_id, "original_", result_id, import_route_section_id, original_line_item_set_id, 4)
            insert_line_items(quotation_id, "", result_id, import_route_section_id, edited_line_item_set_id, 4) if edited_line_item_set_id.present?

            insert_cargo_line_items(quotation_id, "original_", result_id, import_route_section_id, original_line_item_set_id, 4)
            insert_cargo_line_items(quotation_id, "original_", result_id, import_route_section_id, edited_line_item_set_id, 4) if edited_line_item_set_id.present?
          end

          next unless line_items.trucking_on_section.any?

          from = destination_route_point.dup
          to = insert_carriage_route_point(quotation.delivery_address)

          from.save
          on_carriage_route_section_id = insert_on_carriage_route_section(result_id, quotation_id, from, to)
          insert_line_items(quotation_id, "original_", result_id, on_carriage_route_section_id, original_line_item_set_id, 5)
          insert_line_items(quotation_id, "", result_id, on_carriage_route_section_id, edited_line_item_set_id, 5) if edited_line_item_set_id.present?

          insert_cargo_line_items(quotation_id, "original_", result_id, on_carriage_route_section_id, original_line_item_set_id, 5)
          insert_cargo_line_items(quotation_id, "original_", result_id, on_carriage_route_section_id, edited_line_item_set_id, 5) if edited_line_item_set_id.present?
        end
        insert_commodity_info(quotation_id)
        update_exchange_rate(quotation_id: quotation_id, result_set_id: result_set_id)

        at index, "quotation #{index} done"
        store current_quotation: quotation_id
      end
    rescue CountValidationError => e
    rescue RateNotFoundError => e
    end
  end

  def insert_carriage_route_point(address)
    address ||= deleted_address
    existing = Journey::RoutePoint.find_by(name: address.geocoded_address)

    Journey::RoutePoint.create(
      name: address.geocoded_address,
      function: "carriage",
      coordinates: address.point,
      postal_code: address.zip_code,
      city: address.city,
      street: address.street,
      street_number: address.street_number,
      administrative_area: "",
      country: address.country&.code || "unknown",
      geo_id: existing&.geo_id || "itsmycargo:BACKFILL-#{SecureRandom.uuid}"
    )
  end

  def insert_freight_route_point(nexus)
    nexus ||= deleted_nexus
    existing = Journey::RoutePoint.find_by(locode: nexus.locode)

    Journey::RoutePoint.create(
      name: nexus.name,
      locode: nexus.locode,
      function: "port",
      coordinates: RGeo::Geos.factory(srid: 4326).point(nexus.longitude, nexus.latitude),
      geo_id: existing&.geo_id || "itsmycargo:BACKFILL-#{SecureRandom.uuid}"
    )
  end

  def insert_query(quotation_id, fall_back_origin, fall_back_destination)
    query = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_queries (
          id,
          origin,
          origin_coordinates,
          destination,
          destination_coordinates,
          cargo_ready_date,
          delivery_date,
          client_id,
          creator_id,
          company_id,
          organization_id,
          insurance,
          customs,
          billable,
          source_id,
          created_at,
          updated_at)
          SELECT
            DISTINCT ON(quotations_quotations.id) gen_random_uuid(),
            COALESCE(pickup_addresses.geocoded_address, origin_nexuses.name, '#{fall_back_origin}'),
            ST_SetSRID(ST_MakePoint(COALESCE(pickup_addresses.longitude, origin_nexuses.longitude, 0), COALESCE(pickup_addresses.latitude, origin_nexuses.latitude, 0)), 4326),
            COALESCE(delivery_addresses.geocoded_address, destination_nexuses.name, '#{fall_back_destination}'),
            ST_SetSRID(ST_MakePoint(COALESCE(delivery_addresses.longitude, destination_nexuses.longitude, 0), COALESCE(delivery_addresses.latitude, destination_nexuses.latitude, 0)), 4326),
            LEAST(shipments.planned_pickup_date, shipments.planned_origin_drop_off_date, quotations_quotations.selected_date, quotations_quotations.created_at),
            COALESCE(shipments.planned_delivery_date, shipments.planned_destination_collection_date, COALESCE(quotations_quotations.selected_date, quotations_quotations.created_at)+ INTERVAL '25 DAY'),
            quotations_quotations.user_id,
            quotations_quotations.creator_id,
            companies_memberships.company_id,
            quotations_quotations.organization_id,
            CASE WHEN EXISTS(
              SELECT *
              FROM quotations_line_items
              JOIN quotations_tenders
                  ON quotations_tenders.id = quotations_line_items.tender_id
                  AND quotations_tenders.quotation_id = quotations_quotations.id
              WHERE section = 7)
            THEN CAST(true AS boolean)
            ELSE CAST(false AS boolean) END,
            CASE WHEN EXISTS (
              SELECT *
              FROM quotations_line_items
              JOIN quotations_tenders
                ON quotations_tenders.id = quotations_line_items.tender_id
                AND quotations_tenders.quotation_id = quotations_quotations.id
              WHERE section = 6)
            THEN CAST(true AS boolean)
            ELSE CAST(false AS boolean) END,
          CASE WHEN (quotations_quotations.billing = 2)
          THEN CAST(false AS boolean)
          ELSE CAST(true AS boolean) END,
          CASE WHEN (quotations_quotations.user_id != quotations_quotations.creator_id)
          THEN (select id from oauth_applications where name = 'bridge' limit 1) -- Bridge Doorkeepr Application Id
          ELSE (select id from oauth_applications where name = 'dipper' limit 1) -- Dipper Doorkeepr Application Id
          END,
          quotations_quotations.created_at,
          quotations_quotations.updated_at
        FROM quotations_quotations
        LEFT JOIN addresses pickup_addresses
          ON pickup_addresses.id = quotations_quotations.pickup_address_id
        LEFT JOIN addresses delivery_addresses
          ON delivery_addresses.id = quotations_quotations.delivery_address_id
        LEFT JOIN nexuses origin_nexuses
          ON origin_nexuses.id = quotations_quotations.origin_nexus_id
        LEFT JOIN nexuses destination_nexuses
          ON destination_nexuses.id = quotations_quotations.destination_nexus_id
        LEFT JOIN shipments
          ON shipments.id = quotations_quotations.legacy_shipment_id
        LEFT JOIN quotations_tenders
          ON quotations_tenders.quotation_id = quotations_quotations.id
        LEFT JOIN quotations_line_items
          ON quotations_tenders.id = quotations_line_items.tender_id
        LEFT JOIN companies_memberships
          ON quotations_quotations.user_id = companies_memberships.member_id
          AND companies_memberships.member_type = 'Users::Client' ,
          oauth_applications
        WHERE quotations_quotations.id = '#{quotation_id}'
        RETURNING id
      SQL
    )

    validate_count(quotation_id: quotation_id, model: "query", must_be: 1, is: query.count)
    query.field_values("id").first
  end

  def insert_cargo_units(quotation_id, query_id)
    cargo_units = ActiveRecord::Base.connection.execute(
      <<~SQL
        WITH  cargo_class_map (c_class, c_type, new_val) AS (
          VALUES
          (27,	2, 'fcl_20'),
          (53,	2, 'fcl_40'),
          (53,	24, 'fcl_40_rf'),
          (55,	2, 'fcl_40_hq'),
          (0, 0, 'lcl'),
          (183, 2, 'fcl_45_hq'),
          (0,	1, 'aggregated_lcl')
        )

          INSERT INTO journey_cargo_units (
            id,
            cargo_class,
            height_unit,
            height_value,
            length_unit,
            length_value,
            quantity,
            stackable,
            weight_unit,
            weight_value,
            width_unit,
            width_value,
            volume_value,
            volume_unit,
            created_at,
            updated_at,
            query_id)
          SELECT
            cargo_units.id,
            cargo_class_map.new_val,
            cargo_units.height_unit,
            cargo_units.height_value,
            cargo_units.length_unit,
            cargo_units.length_value,
            cargo_units.quantity,
            cargo_units.stackable,
            cargo_units.weight_unit,
            GREATEST(cargo_units.weight_value, 0.0001),
            cargo_units.width_unit,
            cargo_units.width_value,
            (cargo_units.height_value * cargo_units.length_value * cargo_units.width_value),
            'm3',
            cargo_units.created_at,
            cargo_units.updated_at,
            '#{query_id}'
          FROM cargo_units
          JOIN cargo_class_map
          ON cargo_class_map.c_class = cargo_units.cargo_class
          AND cargo_class_map.c_type = cargo_units.cargo_type
          JOIN cargo_cargos
            ON cargo_cargos.id = cargo_units.cargo_id
          JOIN quotations_quotations
            ON cargo_cargos.quotation_id = quotations_quotations.id
          LEFT JOIN cargo_items
            ON cargo_units.legacy_id = cargo_items.id
            AND cargo_units.legacy_type = 'Legacy::CargoItem'
          LEFT JOIN containers
            ON cargo_units.legacy_id = containers.id
            AND cargo_units.legacy_type = 'Legacy::Container'
          LEFT JOIN aggregated_cargos
            ON cargo_units.legacy_id = aggregated_cargos.id
            AND cargo_units.legacy_type = 'Legacy::AggregatedCargo'
            WHERE quotations_quotations.id = '#{quotation_id}'
          RETURNING id;
      SQL
    )
    must_count = Cargo::Unit
      .joins(:cargo)
      .joins("JOIN quotations_quotations
      ON cargo_cargos.quotation_id = quotations_quotations.id")
      .where("quotations_quotations.id = ?", quotation_id)
      .distinct
      .count

    validate_count(quotation_id: quotation_id, model: "cargo_unit", must_be: must_count, is: cargo_units.count)
  end

  def insert_result_sets(query_id, quotation_id)
    result_sets = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_result_sets (
          id,
          status,
          currency,
          query_id,
          created_at,
          updated_at)
          SELECT
            DISTINCT ON(quotations_quotations.id) gen_random_uuid(),
            CASE WHEN (quotations_quotations.error_class IS NULL)
            THEN 'completed'::journey_status
            ELSE 'failed'::journey_status END,
            COALESCE(quotations_tenders.amount_currency, 'EUR'),
            '#{query_id}',
            quotations_quotations.created_at,
            quotations_quotations.updated_at
        FROM quotations_quotations
        LEFT JOIN quotations_tenders
          ON quotations_tenders.quotation_id = quotations_quotations.id
        WHERE quotations_quotations.id = '#{quotation_id}'
        RETURNING id;
      SQL
    )

    validate_count(quotation_id: quotation_id, model: "result_set", must_be: 1, is: result_sets.count)

    result_sets.field_values("id").first
  end

  def insert_offer(query_id, quotation_id)
    offer = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_offers (
          id,
          query_id,
          created_at,
          updated_at)
        SELECT
          gen_random_uuid(),
          '#{query_id}',
          quotations_quotations.created_at,
          quotations_quotations.updated_at
        FROM quotations_quotations
        WHERE quotations_quotations.id = '#{quotation_id}'
        RETURNING id;
      SQL
    )

    validate_count(quotation_id: quotation_id, model: "offer", must_be: 1, is: offer.count)

    offer.field_values("id").first
  end

  def insert_error(result_set_id, quotation)
    error_key = quotation.error_class.split("::").last.underscore
    error = I18n.t("error.#{error_key}", default: { code: 422, message: "something went wrong" })

    errors = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_errors (
          id,
          code,
          property,
          created_at,
          updated_at,
          result_set_id)
        SELECT
          gen_random_uuid(),
          '#{error[:code]}',
          '#{error[:message]}',
          quotations_quotations.created_at,
          quotations_quotations.created_at,
          '#{result_set_id}'::uuid
        FROM quotations_quotations
        WHERE quotations_quotations.id = '#{quotation.id}'
        RETURNING id;
      SQL
    )

    validate_count(quotation_id: quotation.id, model: "error", must_be: 1, is: errors.count)
  end

  def insert_results(result_set_id, quotation_id)
    results = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_results (
          id,
          expiration_date,
          issued_at,
          created_at,
          updated_at,
          result_set_id)
          SELECT
            distinct on (quotations_tenders.id) quotations_tenders.id,
            COALESCE(charge_breakdowns.valid_until, (quotations_quotations.created_at+ INTERVAL '14 DAY')),
            quotations_tenders.created_at,
            quotations_tenders.created_at,
            quotations_tenders.updated_at,
            '#{result_set_id}'
        FROM quotations_tenders
        JOIN quotations_quotations
          ON quotations_quotations.id = quotations_tenders.quotation_id
        LEFT JOIN charge_breakdowns
          ON charge_breakdowns.tender_id = quotations_tenders.id
        WHERE quotations_quotations.id = '#{quotation_id}'
        RETURNING id;
      SQL
    )
    tenders_count = Quotations::Tender.where(quotation_id: quotation_id).count

    validate_count(quotation_id: quotation_id, model: "result", must_be: tenders_count, is: results.count)

    results.field_values("id")
  end

  def insert_original_line_item_set(result_id, quotation_id)
    line_item_sets = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_line_item_sets (
          id,
          created_at,
          updated_at,
          result_id,
          shipment_request_id)
          SELECT
            gen_random_uuid(),
            quotations_tenders.created_at,
            quotations_tenders.created_at,
            '#{result_id}',
            NULL
          FROM quotations_tenders
            WHERE quotations_tenders.id = '#{result_id}'
        RETURNING id
      SQL
    )

    validate_count(quotation_id: quotation_id, model: "line_item_set", must_be: 1, is: line_item_sets.count)

    line_item_sets.field_values("id").first
  end

  def insert_edited_line_item_set(result_id, quotation_id)
    line_item_sets = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_line_item_sets (
          id,
          created_at,
          updated_at,
          result_id,
          shipment_request_id)
          SELECT
          DISTINCT ON(quotations_tenders.id) gen_random_uuid(),
            quotations_tenders.updated_at + INTERVAL '10 SECOND',
            quotations_tenders.updated_at + INTERVAL '10 SECOND',
            '#{result_id}',
            NULL
          FROM quotations_tenders
            JOIN quotations_line_items
              ON quotations_line_items.tender_id = quotations_tenders.id
          WHERE quotations_tenders.id = '#{result_id}'
          AND quotations_line_items.amount_cents != quotations_line_items.original_amount_cents
        RETURNING id
      SQL
    )
    lis = line_item_sets.field_values("id").first

    edited_tender_count = if Quotations::LineItem
        .where(tender_id: result_id)
        .where("quotations_line_items.amount_cents != quotations_line_items.original_amount_cents")
        .any?
      1
    else
      0
end

    validate_count(quotation_id: quotation_id, model: "line_item_set", must_be: edited_tender_count, is: line_item_sets.count)

    lis == "" ? nil : lis
  end

  def insert_original_offer_line_item_set(offer_id, original_line_item_set_id, quotation_id)
    of_li_s = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_offer_line_item_sets (
          id,
          offer_id,
          line_item_set_id,
          created_at,
          updated_at)
        SELECT
          gen_random_uuid(),
          '#{offer_id}',
          '#{original_line_item_set_id}',
          quotations_quotations.created_at,
          quotations_quotations.updated_at
        FROM quotations_quotations
        WHERE quotations_quotations.id = '#{quotation_id}'
        RETURNING id;
      SQL
    )

    validate_count(quotation_id: quotation_id, model: "offer_line_item_set", must_be: 1, is: of_li_s.count)
  end

  def insert_pre_carriage_route_section(result_id, quotation_id, from_point, to_point)
    route_section = ActiveRecord::Base.connection.execute(
      <<~SQL
        WITH route_section AS (
        SELECT
            distinct
            COALESCE(NULLIF(TRIM(UPPER(carriers.code)), ''), organizations_organizations.slug) carrier,
            'carriage'::journey_mode_of_transport mode_of_transport,
            0 transit_time,
            0 "order",
            COALESCE(tenant_vehicles.name, 'standard') service,
            quotations_tenders.created_at created_at,
            quotations_tenders.created_at updated_at,
            '#{from_point.id}'::uuid from_id,
            '#{result_id}'::uuid as result_id,
            '#{to_point.id}'::uuid to_id
          FROM quotations_tenders
            JOIN quotations_quotations
            ON quotations_quotations.id = quotations_tenders.quotation_id
            JOIN organizations_organizations
            ON organizations_organizations.id = quotations_quotations.organization_id
            LEFT JOIN tenant_vehicles
            ON tenant_vehicles.id = quotations_tenders.pickup_tenant_vehicle_id
            LEFT JOIN carriers
            ON carriers.id = tenant_vehicles.carrier_id
          WHERE quotations_tenders.id = '#{result_id}'
          )

        #{insert_route_section}
      SQL
    )

    li_count = Quotations::LineItem.where(tender_id: result_id, section: :trucking_pre_section).any? ? 1 : 0

    validate_count(quotation_id: quotation_id, model: "route_section", must_be: li_count, is: route_section.count)

    route_section.field_values("id").first
  end

  def insert_export_route_section(result_id, quotation_id, from_point, to_point)
    route_section = ActiveRecord::Base.connection.execute(
      <<~SQL
          WITH route_section AS (
          SELECT
          distinct on (quotations_tenders.id) quotations_tenders.id,
          COALESCE(NULLIF(TRIM(UPPER(carriers.code)), ''), organizations_organizations.slug) carrier,
          COALESCE(LOWER(itineraries.mode_of_transport), hubs.hub_type, 'ocean')::journey_mode_of_transport mode_of_transport,
          0 transit_time,
          1 "order",
          COALESCE(tenant_vehicles.name, 'standard') service,
          quotations_tenders.created_at created_at,
          quotations_tenders.created_at updated_at,
          '#{from_point.id}'::uuid from_id,
          '#{result_id}'::uuid result_id,
          '#{to_point.id}'::uuid to_id
        FROM quotations_tenders
          JOIN quotations_quotations
            ON quotations_quotations.id = quotations_tenders.quotation_id
          JOIN organizations_organizations
            ON organizations_organizations.id = quotations_quotations.organization_id
          LEFT JOIN tenant_vehicles
            ON tenant_vehicles.id = quotations_tenders.tenant_vehicle_id
          LEFT JOIN carriers
          ON carriers.id = tenant_vehicles.carrier_id
          LEFT JOIN itineraries
          ON quotations_tenders.itinerary_id = itineraries.id
          LEFT JOIN hubs
          ON
            quotations_tenders.origin_hub_id = hubs.id
          OR
            quotations_tenders.destination_hub_id = hubs.id
          WHERE quotations_tenders.id = '#{result_id}'
          )
          #{insert_route_section}
      SQL
    )
    li_count = Quotations::LineItem.where(tender_id: result_id, section: :export_section).any? ? 1 : 0

    validate_count(quotation_id: quotation_id, model: "route_section", must_be: li_count, is: route_section.count)

    route_section.field_values("id").first
  end

  def insert_main_freight_route_section(result_id, quotation_id, from_point, to_point)
    route_section = ActiveRecord::Base.connection.execute(
      <<~SQL
         WITH route_section AS (
         SELECT
         distinct on (quotations_tenders.id) quotations_tenders.id,
         COALESCE(NULLIF(TRIM(UPPER(carriers.code)), ''), organizations_organizations.slug) carrier,
         COALESCE(LOWER(itineraries.mode_of_transport), hubs.hub_type, 'ocean')::journey_mode_of_transport mode_of_transport,
         COALESCE(legacy_transit_times.duration, 25) transit_time,
         2 "order",
         COALESCE(tenant_vehicles.name, 'standard') service,
         quotations_tenders.created_at created_at,
         quotations_tenders.created_at updated_at,
         '#{from_point.id}'::uuid from_id,
         '#{result_id}'::uuid result_id,
         '#{to_point.id}'::uuid to_id
         FROM quotations_tenders
         JOIN quotations_quotations
           ON quotations_quotations.id = quotations_tenders.quotation_id
         JOIN organizations_organizations
           ON organizations_organizations.id = quotations_quotations.organization_id
         LEFT JOIN tenant_vehicles
           ON tenant_vehicles.id = quotations_tenders.tenant_vehicle_id
         LEFT JOIN carriers
           ON carriers.id = tenant_vehicles.carrier_id
         LEFT JOIN legacy_transit_times
           ON legacy_transit_times.tenant_vehicle_id = quotations_tenders.tenant_vehicle_id
           AND legacy_transit_times.itinerary_id = quotations_tenders.itinerary_id
         LEFT JOIN itineraries
           ON quotations_tenders.itinerary_id = itineraries.id
         LEFT JOIN hubs
           ON
             quotations_tenders.origin_hub_id = hubs.id
           OR
             quotations_tenders.destination_hub_id = hubs.id
        WHERE quotations_tenders.id = '#{result_id}'
        )

        #{insert_route_section}
      SQL
    )

    li_count = Quotations::LineItem.where(tender_id: result_id, section: :cargo_section).any? ? 1 : 0

    validate_count(quotation_id: quotation_id, model: "route_section", must_be: li_count, is: route_section.count)

    route_section.field_values("id").first
  end

  def insert_import_route_section(result_id, quotation_id, from_point, to_point)
    route_section = ActiveRecord::Base.connection.execute(
      <<~SQL
        WITH route_section AS (
          SELECT
            distinct on (quotations_tenders.id) quotations_tenders.id,
            COALESCE(NULLIF(TRIM(UPPER(carriers.code)), ''), organizations_organizations.slug) carrier,
            COALESCE(LOWER(itineraries.mode_of_transport), hubs.hub_type, 'ocean')::journey_mode_of_transport mode_of_transport,
            0 transit_time,
            3 "order",
            COALESCE(tenant_vehicles.name, 'standard') service,
            quotations_tenders.created_at created_at,
            quotations_tenders.created_at updated_at,
            '#{from_point.id}'::uuid from_id,
            '#{result_id}'::uuid result_id,
            '#{to_point.id}'::uuid to_id
            FROM quotations_tenders
            JOIN quotations_quotations
              ON quotations_quotations.id = quotations_tenders.quotation_id
            JOIN organizations_organizations
              ON organizations_organizations.id = quotations_quotations.organization_id
            LEFT JOIN tenant_vehicles
              ON tenant_vehicles.id = quotations_tenders.tenant_vehicle_id
            LEFT JOIN carriers
            ON carriers.id = tenant_vehicles.carrier_id
            LEFT JOIN itineraries
              ON quotations_tenders.itinerary_id = itineraries.id
            LEFT JOIN hubs
            ON
              quotations_tenders.origin_hub_id = hubs.id
            OR
              quotations_tenders.destination_hub_id = hubs.id
          WHERE quotations_tenders.id = '#{result_id}'
        )
          #{insert_route_section}
      SQL
    )

    li_count = Quotations::LineItem.where(tender_id: result_id, section: :import_section).any? ? 1 : 0

    validate_count(quotation_id: quotation_id, model: "route_section", must_be: li_count, is: route_section.count)

    route_section.field_values("id").first
  end

  def insert_on_carriage_route_section(result_id, quotation_id, from_point, to_point)
    route_section = ActiveRecord::Base.connection.execute(
      <<~SQL
        WITH route_section AS (
        SELECT
          COALESCE(NULLIF(TRIM(UPPER(carriers.code)), ''), organizations_organizations.slug) carrier,
          'carriage'::journey_mode_of_transport mode_of_transport,
          0 transit_time,
          4 "order",
          COALESCE(tenant_vehicles.name, 'standard') service,
          quotations_tenders.created_at created_at,
          quotations_tenders.created_at updated_at,
          '#{from_point.id}'::uuid from_id,
          '#{result_id}'::uuid result_id,
          '#{to_point.id}'::uuid to_id
        FROM quotations_tenders
          JOIN quotations_quotations
          ON quotations_quotations.id = quotations_tenders.quotation_id
          JOIN organizations_organizations
          ON organizations_organizations.id = quotations_quotations.organization_id
          LEFT JOIN tenant_vehicles
          ON tenant_vehicles.id = quotations_tenders.delivery_tenant_vehicle_id
          LEFT JOIN carriers
          ON carriers.id = tenant_vehicles.carrier_id
          WHERE quotations_tenders.id = '#{result_id}'
        )
        #{insert_route_section}
      SQL
    )

    li_count = Quotations::LineItem.where(tender_id: result_id, section: :trucking_on_section).any? ? 1 : 0

    validate_count(quotation_id: quotation_id, model: "route_section", must_be: li_count, is: route_section.count)

    route_section.field_values("id").first
  end

  def insert_route_section
    'INSERT INTO journey_route_sections (
      "id",
      "carrier",
      "mode_of_transport",
      "transit_time",
      "order",
      "service",
      "created_at",
      "updated_at",
      "from_id",
      "result_id",
      "to_id")
      SELECT
        gen_random_uuid(),
        carrier,
        mode_of_transport,
        transit_time,
        "order",
        service,
        created_at,
        updated_at,
        from_id,
        result_id,
        to_id
      FROM route_section
      RETURNING *'
  end

  def insert_line_items(quotation_id, type, result_id, route_section_id, line_item_set_id, section)
    new_line_items = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_line_items (
        id,
        description,
        fee_code,
        included,
        note,
        optional,
        "order",
        total_cents,
        total_currency,
        unit_price_cents,
        unit_price_currency,
        units,
        wm_rate,
        created_at,
        updated_at,
        line_item_set_id,
        route_point_id,
        route_section_id)
        SELECT
        gen_random_uuid(),
        COALESCE(charge_categories.name, CONCAT('BACKFILL-FEE-NAME-',gen_random_uuid())),
        COALESCE(charge_categories.code, CONCAT('BACKFILL-FEE-CODE-',gen_random_uuid())),
        CASE WHEN EXISTS (
          SELECT *
          FROM charge_categories
          JOIN quotations_line_items
              ON charge_categories.id = quotations_line_items.charge_category_id
              AND quotations_line_items.tender_id = quotations_tenders.id
          WHERE code LIKE 'included_%'
        )
        THEN CAST(true AS boolean)
        ELSE CAST(false AS boolean) END,
        '',
        false,
        quotations_line_items.section,
        quotations_line_items.#{type}amount_cents,
        COALESCE(quotations_line_items.#{type}amount_currency, 'USD'),
        quotations_line_items.#{type}amount_cents / 1,
        COALESCE(quotations_line_items.#{type}amount_currency, 'USD'),
        1,
        1,
        quotations_line_items.created_at,
        quotations_line_items.updated_at,
        '#{line_item_set_id}',
        NULL,
        '#{route_section_id}'
        FROM quotations_line_items
        JOIN quotations_tenders
          ON quotations_tenders.id = quotations_line_items.tender_id
        JOIN quotations_quotations
          ON quotations_quotations.id = quotations_tenders.quotation_id
        LEFT JOIN charge_categories
          ON charge_categories.id = quotations_line_items.charge_category_id
        WHERE quotations_tenders.id = '#{result_id}'
        AND quotations_line_items.section = '#{section}'
        AND quotations_line_items.cargo_id IS NULL
        RETURNING id
      SQL
    )

    old_line_items = Quotations::LineItem.where(tender_id: result_id, section: section).where("cargo_id IS NULL")
    validate_count(quotation_id: quotation_id, model: "line_item", must_be: old_line_items.count, is: new_line_items.count)
  end

  def insert_cargo_line_items(quotation_id, type, result_id, route_section_id, line_item_set_id, section)
    new_line_items = ActiveRecord::Base.connection.execute(
      <<~SQL
        WITH temp (old_li_id, cargo_id, new_li_id) AS (
          select id, cargo_id, gen_random_uuid()
          from quotations_line_items
          where cargo_id is not null
          AND tender_id = '#{result_id}'
        )
        , new_line_items AS (
          INSERT INTO journey_line_items (
          id,
          description,
          fee_code,
          included,
          note,
          optional,
          "order",
          total_cents,
          total_currency,
          unit_price_cents,
          unit_price_currency,
          units,
          wm_rate,
          created_at,
          updated_at,
          line_item_set_id,
          route_point_id,
          route_section_id)
          SELECT
          temp.new_li_id,
          COALESCE(charge_categories.name, CONCAT('BACKFILL-FEE-NAME-',gen_random_uuid())),
          COALESCE(charge_categories.code, CONCAT('BACKFILL-FEE-CODE-',gen_random_uuid())),
          CASE WHEN EXISTS (
            SELECT *
            FROM charge_categories
            JOIN quotations_line_items
                ON charge_categories.id = quotations_line_items.charge_category_id
                AND quotations_line_items.tender_id = quotations_tenders.id
            WHERE code LIKE 'included_%'
          )
          THEN CAST(true AS boolean)
          ELSE CAST(false AS boolean) END,
          '',
          false,
          quotations_line_items.section,
          quotations_line_items.#{type}amount_cents,
          COALESCE(quotations_line_items.#{type}amount_currency, 'USD'),
          quotations_line_items.#{type}amount_cents / (COALESCE(cargo_items.quantity, containers.quantity, 1)),
          COALESCE(quotations_line_items.#{type}amount_currency, 'USD'),
          (COALESCE(cargo_items.quantity, containers.quantity, 1)),
          1,
          quotations_line_items.created_at,
          quotations_line_items.updated_at,
          '#{line_item_set_id}',
          NULL,
          '#{route_section_id}'
          FROM quotations_line_items
          JOIN temp
          ON quotations_line_items.id = temp.old_li_id
          JOIN quotations_tenders
            ON quotations_tenders.id = quotations_line_items.tender_id
          JOIN quotations_quotations
            ON quotations_quotations.id = quotations_tenders.quotation_id
          LEFT JOIN charge_categories
            ON charge_categories.id = quotations_line_items.charge_category_id
          LEFT JOIN containers
            ON quotations_line_items.cargo_id = containers.id
            AND quotations_line_items.cargo_type = 'Legacy::Container'
          LEFT JOIN cargo_items
            ON quotations_line_items.cargo_id = cargo_items.id
            AND quotations_line_items.cargo_type = 'Legacy::CargoItem'
          LEFT JOIN aggregated_cargos
            ON quotations_line_items.cargo_id = aggregated_cargos.id
            AND quotations_line_items.cargo_type = 'Legacy::AggregatedCargo'
          WHERE quotations_tenders.id = '#{result_id}'
          AND quotations_line_items.section = '#{section}'
          AND quotations_line_items.cargo_id IS NOT NULL
          RETURNING *
        )

        INSERT INTO journey_line_item_cargo_units (
          id,
          cargo_unit_id,
          line_item_id,
          created_at,
          updated_at
          )
        SELECT
          gen_random_uuid(),
          cargo_units.id,
          temp.new_li_id,
          new_line_items.created_at,
          new_line_items.updated_at
         FROM new_line_items
         JOIN temp
         ON temp.new_li_id = new_line_items.id
         JOIN cargo_units
         ON cargo_units.legacy_id = temp.cargo_id
         JOIN journey_cargo_units
         ON journey_cargo_units.id = cargo_units.id
        returning *
      SQL
    )

    old_line_items = Quotations::LineItem
      .joins("JOIN cargo_units ON cargo_units.legacy_id = quotations_line_items.cargo_id")
      .where(tender_id: result_id, section: section)
      .where("quotations_line_items.cargo_id IS NOT NULL")
      .distinct

    validate_count(quotation_id: quotation_id, model: "line_item_cargo_units", must_be: old_line_items.count, is: new_line_items.count)
  end

  def insert_commodity_info(quotation_id)
    commodity_info = ActiveRecord::Base.connection.execute(
      <<~SQL
        INSERT INTO journey_commodity_infos (
          id,
          description,
          hs_code,
          imo_class,
          created_at,
          updated_at,
          cargo_unit_id)
        SELECT
          gen_random_uuid(),
          'Unknown IMO Class',
          '',
          '0',
          cargo_units.created_at,
          cargo_units.updated_at,
          cargo_units.id
        FROM cargo_units
        JOIN cargo_cargos
          ON cargo_cargos.id = cargo_units.cargo_id
        JOIN quotations_quotations
          ON cargo_cargos.quotation_id = quotations_quotations.id
        JOIN journey_cargo_units
          ON cargo_units.id = journey_cargo_units.id
        WHERE quotations_quotations.id = '#{quotation_id}'
        AND cargo_units.dangerous_goods IS NOT NULL
        RETURNING id
      SQL
    )

    units_count = Cargo::Unit.joins(:cargo).where("quotation_id = ?", quotation_id).where.not(dangerous_goods: nil).count

    validate_count(quotation_id: quotation_id, model: "commodity_infos", must_be: units_count, is: commodity_info.count)
  end

  def validate_count(quotation_id:, model:, must_be:, is:)
    if is != must_be
      register_error(quotation_id: quotation_id, model: model, must_be: must_be, is: is)

      raise CountValidationError
    end
  end

  def register_error(quotation_id:, model:, must_be:, is:)
    parsed = JSON.parse @failed_quotations
    parsed[quotation_id.to_s] = "number of rows inserted into #{model} must be #{must_be} but it's #{is}"
    @failed_quotations = parsed.to_json
    store failed_quotations: @failed_quotations
  end

  def deleted_nexus
    Legacy::Nexus.new(
      name: "deleted",
      locode: "deleted",
      longitude: 0,
      latitude: 0
    )
  end

  def deleted_address
    Legacy::Address.new(
      geocoded_address: "deleted",
      point: RGeo::Geos.factory(srid: 4326).point(0, 0)
    )
  end

  def create_deleted_point
    Journey::RoutePoint.create(
      name: "deleted",
      locode: "deleted",
      function: "port",
      coordinates: RGeo::Geos.factory(srid: 4326).point(0, 0),
      geo_id: "deleted"
    )
  end

  def update_exchange_rate(quotation_id:, result_set_id:)
    Journey::ResultSet.where(id: result_set_id).find_each do |result_set|
      bank = bank_for_date(date: result_set.created_at)
      Journey::LineItem.where(line_item_set: result_set.results.flat_map(&:line_item_sets))
        .group_by(&:total_currency)
        .each do |currency, line_items|
          if currency == result_set.currency
            rate = 1
          else
            rate = bank.get_rate(currency, result_set.currency)

            if rate.blank?
              register_error(quotation_id: quotation_id, model: "exchange_rate", must_be: 1, is: 0)

              raise RateNotFoundError
            end
          end

          Journey::LineItem.where(id: line_items.map(&:id)).update_all(exchange_rate: rate)
        end
    end
  end

  def bank_for_date(date:)
    store = MoneyCache::Converter.new(
      klass: Treasury::ExchangeRate,
      date: [date, DateTime.new(2020, 0o3, 0o5, 0, 0, 0)].max,
      config: { bank_app_id: Settings.open_exchange_rate&.app_id || "" }
    )
    Money::Bank::VariableExchange.new(store)
  end
end
