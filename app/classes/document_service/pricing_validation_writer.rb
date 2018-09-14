# frozen_string_literal: true

module DocumentService
  class PricingValidationWriter
    include AwsConfig
    include WritingTool
    attr_reader :options, :filename, :tenant, :pricings, :aux_data, :dir, :workbook, :worksheet

    def initialize(options)
      @options         = options
      @filename        = filename_formatter(options)
      @data            = options[:data]
      @tenant          = tenant_finder(options[:tenant_id])
      @dir             = "tmp/#{filename}"
      workbook_hash    = add_worksheet_to_workbook(create_workbook(@dir), pricing_sheet_header_text)
      @workbook        = workbook_hash[:workbook]
      @worksheet       = workbook_hash[:worksheet]
    end

    def perform
      row = 1
      @data.each do |itinerary_id, results|
        results.each do |example_index, result|
          result[:all].each do |result_hash|
            data = [
              result_hash[:itinerary][:name],
              result_hash[:example_number],
              result_hash[:service_level].name,
              result_hash[:expected_total],
              result_hash[:total],
              result_hash[:diff_val],
              result_hash[:diff_percent],
              result_hash[:expected_trucking_pre],
              result_hash[:trucking_pre],
              result_hash[:trucking_pre_diff_val],
              result_hash[:trucking_pre_diff_percent],
              result_hash[:expected_trucking_on],
              result_hash[:trucking_on],
              result_hash[:trucking_on_diff_val],
              result_hash[:trucking_on_diff_percent],
              result_hash[:expected_import],
              result_hash[:import],
              result_hash[:import_diff_val],
              result_hash[:import_diff_percent],
              result_hash[:expected_export],
              result_hash[:export],
              result_hash[:export_diff_val],
              result_hash[:export_diff_percent]
            ]
            @worksheet = write_to_sheet(worksheet, row, 0, data)
            row += 1
          end
        end
      end
      workbook.close
      write_to_aws(dir, tenant, filename, "pricings_sheet")
    end

    private

    def pricing_sheet_header_text
      %w(ITINERARY EXAMPLE_NO SERVICE_LEVEL TOTAL_EXPECTED TOTAL_ACTUAL TOTAL_DIFF TOTAL_%
        PRECARRIAGE_EXPECTED PRECARRIAGE_ACTUAL PRECARRIAGE_DIFF PRECARRIAGE_%
        ONCARRIAGE_EXPECTED ONCARRIAGE_ACTUAL ONCARRIAGE_DIFF ONCARRIAGE_%
        IMPORT_EXPECTED IMPORT_ACTUAL IMPORT_DIFF IMPORT_%
        EXPORT_EXPECTED EXPORT_ACTUAL EXPORT_DIFF EXPORT_%
        )
    end

    def layover_hash(current_itinerary, pricing)
      tmp_trip = current_itinerary.trips.last
      key_origin = aux_data[:itineraries][pricing[:itinerary_id]]["stops"][0]["id"]
      key_destination = aux_data[:itineraries][pricing[:itinerary_id]]["stops"][1]["id"]
      if tmp_trip
        destination_layover = nil
        origin_layover = nil
        tmp_layovers = current_itinerary.trips.last.layovers
        tmp_layovers.each do |lay|
          origin_layover = lay if lay.stop_id == key_origin.to_i
          destination_layover = lay if lay.stop_id == key_destination.to_i
        end
        diff = ((tmp_trip.end_date - tmp_trip.start_date) / 86_400).to_i
        aux_data[:transit_times]["#{key_origin}_#{key_destination}"] = diff
      else
        aux_data[:transit_times]["#{key_origin}_#{key_destination}"] = ""
      end

      {
        destination_layover: destination_layover,
        origin_layover:      origin_layover,
        aux_data:            aux_data
      }
    end

    def get_tenant_pricings_by_mot(tenant_id, mot)
      itinerary_ids = Tenant.find(tenant_id).itineraries.where(mode_of_transport: mot).ids
      Pricing.where(itinerary_id: itinerary_ids).map(&:as_json)
    end

    def get_tenant_pricings(tenant_id)
      Pricing.where(tenant_id: tenant_id).map(&:as_json)
    end

    def map_itin_pricings(itin)
      itin.pricings.map(&:as_json)
    end
  end
end
