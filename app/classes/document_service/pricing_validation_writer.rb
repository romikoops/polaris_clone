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
      @workbook        = create_workbook(@dir)
    end

    def perform
      @data.each do |page, column_hash|
        @row = 0
        next if column_hash.values.empty?
        header_data = build_header_rows(column_hash)
        new_worksheet_hash = add_worksheet_to_workbook(@workbook, [], page)
        @worksheet = new_worksheet_hash[:worksheet]
        @workbook = new_worksheet_hash[:workbook]
        # begin
        #   set_formatting(column_hash)
        # rescue
        #   binding.pry
        # end
        @worksheet = write_to_sheet(@worksheet, @row, 0, header_data)
        @row += 1

        vertical_headers.each do |header|
          case header
          when 'UNITS'
            write_cargo_units(column_hash)
          when 'IMPORT'
            write_fees('import', column_hash)
          when 'EXPORT'
            write_fees('export', column_hash)
          when 'FREIGHT'
            write_fees('freight', column_hash)
          else
            data = build_writeable_row(header, column_hash)
            @worksheet = write_to_sheet(@worksheet, @row, 0, data)
          end
          @row += 1
        end
      end
      begin
        @workbook.close
      rescue
        binding.pry
      end
      write_to_aws(dir, tenant, filename, 'pricings_sheet')
    end

    private

    def set_formatting(column_hash)
      col = 1
      count = 1
      odd_format = @workbook.add_format
      odd_format.set_bg_color("#14FAFA")
      odd_format.set_shrink()
      even_format = @workbook.add_format
      even_format.set_bg_color("#87FA14")
      even_format.set_shrink()
      column_hash.keys.count.times do
        active_format = count.even? ? even_format : odd_format
        3.times do
          @worksheet.set_column(0, col, active_format)
          col += 1
        end
        count += 1
      end

    end

    def write_fees(target, column_hash)
      top_row = [target.upcase]
      sym_key = target == 'freight' ? :cargo : target.to_sym
      column_hash.values.each do |c_hash|
        top_row << "#{c_hash.dig(:expected, sym_key, :total, :currency)} #{c_hash.dig(:expected, sym_key, :total, :value).try(:to_d).try(:round, 3)}"
        top_row << "#{c_hash.dig(:result, :quote, sym_key, :total, :currency)} #{c_hash.dig(:result, :quote, sym_key, :total, :value)}"
        top_row << c_hash.dig(:diff, sym_key, :total)
      end
      @worksheet = write_to_sheet(@worksheet, @row, 0, top_row)
      @row += 1
      default_fees = column_hash.values.first[:expected][sym_key]
      default_fees.keys.each do |fee_key|
        if fee_key.to_sym != :total && sym_key != :cargo
          fee_row = ["-#{fee_key}"]
          column_hash.values.each do |c_hash|
            fee_row << "#{c_hash.dig(:expected, sym_key, fee_key, :currency)} #{c_hash.dig(:expected, sym_key, fee_key, :value)}"
            fee_row << "#{c_hash.dig(:result, :quote, sym_key, fee_key, :currency)} #{c_hash.dig(:result, :quote, sym_key, fee_key, :value)}"
            fee_row << c_hash.dig(:diff, sym_key, fee_key)
          end
          @worksheet = write_to_sheet(@worksheet, @row, 0, fee_row)
          @row += 1
        elsif fee_key.to_sym != :total
          fee_row = ["-#{fee_key}"]
          column_hash.values.each do |c_hash|
            fee_row << "#{c_hash.dig(:expected, sym_key, fee_key, :currency)} #{c_hash.dig(:expected, sym_key, fee_key, :value)}"
            fee_row << "#{c_hash.dig(:result, :quote, sym_key, :cargo_item, fee_key, :currency)} #{c_hash.dig(:result, :quote, sym_key, :cargo_item, fee_key, :value)}"
            fee_row << c_hash.dig(:diff, sym_key, fee_key)
          end
          @worksheet = write_to_sheet(@worksheet, @row, 0, fee_row)
          @row += 1
        end
      end
    end

    def write_cargo_units(column_hash)
      cargo_units = {}

      @worksheet = write_to_sheet(@worksheet, @row, 0, ['UNITS'])
      @row += 1
      column_hash.keys.each do |column_id|
        cargo_units[column_id] = column_hash[column_id][:data][:cargo_units]
      end
      max_unit_count = cargo_units.values.map(&:count).max
      begin
        example_unit = cargo_units.values.first.first
      rescue StandardError
        binding.pry
      end
      current_unit = 1
      while current_unit <= max_unit_count
        example_unit.keys.each do |example_key|
          unit_row = ["##{current_unit}-#{example_key}"]
          column_hash.keys.each do |c_key|
            next unless cargo_units[c_key][current_unit - 1]
            3.times do
              unit_row << if example_key == 'cargo_item_type_id'
                            CargoItemType.find(cargo_units[c_key][current_unit - 1][example_key]).name
                          else
                            cargo_units[c_key][current_unit - 1][example_key]
                          end
            end
          end
          @worksheet = write_to_sheet(@worksheet, @row, 0, unit_row)
          @row += 1
        end
        current_unit += 1
      end
    end

    def build_writeable_row(header, column_hash)
      row = [header]
      column_hash.keys.each do |column_id|
        result = column_hash[column_id][:result][:quote]
        expected = column_hash[column_id][:expected]
        diff = column_hash[column_id][:diff]
        data = column_hash[column_id][:data]
        case header
        when 'ITINERARY'
          p data[:itinerary][:name]
          3.times do
            row << data[:itinerary][:name]
          end
        when 'MOT'
          3.times do
            row << data[:mode_of_transport]
          end
        when 'LOAD_TYPE'
          3.times do
            row << data[:load_type]
          end
        when 'ORIGIN_TRUCK_TYPE'
          3.times do
            row << data[:origin_truck_type]
          end
        when 'DESTINATION_TRUCK_TYPE'
          3.times do
            row << data[:destination_truck_type]
          end
        when 'PICKUP_ADDRESS'
          3.times do
            row << data[:pickup_address]
          end
        when 'DELIVERY_ADDRESS'
          3.times do
            row << data[:delivery_address]
          end
        when 'CARRIER'
          3.times do
            row << data[:carrier]
          end
        when 'SERVICE_LEVEL'
          3.times do
            row << data[:service_level].try(:name)
          end
        when 'TOTAL'
          result_total = result.dig(:total, :value)
          expected_total = expected.dig(:total, :value)
          row << "#{expected.dig(:total, :currency)} #{expected_total}"
          row << "#{result.dig(:total, :currency)} #{result_total}"
          row << diff.dig(:total)
        when 'PRECARRIAGE'
          if expected[:trucking_pre]
            result_total = result.dig(:trucking_pre, :total, :value)
            expected_total = expected.dig(:trucking_pre, :total, :value)
            row << "#{expected.dig(:trucking_pre, :total, :currency)} #{expected_total}"
            row << "#{result.dig(:trucking_pre, :total, :currency)} #{result_total}"
            row << diff.dig(:trucking_pre, :total)
          end
        when 'ONCARRIAGE'
          if expected[:trucking_on]
            result_total = result.dig(:trucking_on, :total, :value)
            expected_total = expected.dig(:trucking_on, :total, :value)
            row << "#{expected.dig(:trucking_on, :total, :currency)} #{expected_total}"
            row << "#{result.dig(:trucking_on, :total, :currency)} #{result_total}"
            row << diff.dig(:trucking_on, :total)
          end
        end
      end
      row
    end

    def vertical_headers
      %w(
        ITINERARY MOT LOAD_TYPE ORIGIN_TRUCK_TYPE DESTINATION_TRUCK_TYPE
        UNITS PICKUP_ADDRESS DELIVERY_ADDRESS CARRIER SERVICE_LEVEL FREIGHT
        PRECARRIAGE ONCARRIAGE IMPORT EXPORT TOTAL
      )
    end

    def build_header_rows(data)
      header_values = ['']
      data.keys.each do |number|
        header_values << "No: #{number.to_i - 1} - EXPECTED"
        header_values << "No: #{number.to_i - 1} - ACTUAL"
        header_values << "No: #{number.to_i - 1} - DIFF"
      end
      header_values
    end

    def pricing_sheet_header_text
      %w(ITINERARY EXAMPLE_NO SERVICE_LEVEL TOTAL_EXPECTED TOTAL_ACTUAL TOTAL_DIFF TOTAL_%
         PRECARRIAGE_EXPECTED PRECARRIAGE_ACTUAL PRECARRIAGE_DIFF PRECARRIAGE_%
         ONCARRIAGE_EXPECTED ONCARRIAGE_ACTUAL ONCARRIAGE_DIFF ONCARRIAGE_%
         IMPORT_EXPECTED IMPORT_ACTUAL IMPORT_DIFF IMPORT_%
         EXPORT_EXPECTED EXPORT_ACTUAL EXPORT_DIFF EXPORT_%)
    end

    def layover_hash(current_itinerary, pricing)
      tmp_trip = current_itinerary.trips.last
      key_origin = aux_data[:itineraries][pricing[:itinerary_id]]['stops'][0]['id']
      key_destination = aux_data[:itineraries][pricing[:itinerary_id]]['stops'][1]['id']
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
        aux_data[:transit_times]["#{key_origin}_#{key_destination}"] = ''
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
