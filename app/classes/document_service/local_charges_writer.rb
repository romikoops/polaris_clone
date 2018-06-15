# frozen_string_literal: true

module DocumentService
  class LocalChargesWriter
    include WritingTool
    attr_reader :options, :tenant, :hubs, :results_by_hub, :filename, :directory, :header_values, :workbook

    def initialize(options)
      @options          = options
      @tenant           = tenant_finder(options[:tenant_id])
      @hubs             = tenant_hubs
      @results_by_hub   = prepare_results_by_hub
      @filename         = filename_formatter(options, "local_charges_")
      @directory        = "tmp/#{filename}"
      @header_values    = local_charges_header_test
      @workbook         = create_workbook(@directory)
    end

    def perform
      results_by_hub.each do |hub, results|
        row = 1
        workbook_hash = add_worksheet_to_workbook(workbook, header_values, hub)
        @workbook = workbook_hash[:workbook]
        worksheet = workbook_hash[:worksheet]
        results.each do |result|
          result.deep_symbolize_keys!
          counterpart_hub_name = hub_name(result)
          tenant_vehicle_name = vehicle_name(result)
          next unless result[:fees]
          result[:fees].each do |key, fee|
            write_data = local_write_data(fee, key, result, counterpart_hub_name, tenant_vehicle_name)
            if fee[:range] && !fee[:range].empty?
              fee[:range].each do |range_fee|
                worksheet = worksheet_builder({worksheet: worksheet, row: row, start: 0,
                  data: write_data, fee: fee}, range_fee)
                row += 1
              end
            else
              worksheet = worksheet_builder({worksheet: worksheet, row: row, start: 0,
                  data: write_data, fee: fee})
              row += 1
            end
          end
        end
      end
      workbook.close
      write_to_aws(directory, tenant, filename, "local_charges_sheet")
    end

    private

    def hub_name(result)
      if result[:counterpart_hub_id]
        Hub.find(result[:counterpart_hub_id]).name
      else
        ""
      end
    end

    def vehicle_name(result)
      if result[:tenant_vehicle_id]
        TenantVehicle.find(result[:tenant_vehicle_id]).name
      else
        ""
      end
    end

    def local_write_data(fee, key, result, counterpart_hub_name, tenant_vehicle_name)
      data = [fee[:effective_date], fee[:expiration_date], counterpart_hub_name, tenant_vehicle_name, fee[:name]]
      data << result[:mode_of_transport] << key << result[:load_type]
      data << result[:direction] << fee[:currency] << fee[:rate_basis]
      data
    end

    def tenant_hubs
      if options[:mot]
        tenant.hubs.where(hub_type: options[:mot])
      else
        tenant.hubs
      end
    end

    def prepare_results_by_hub
      results_by_hub = {}
      hubs.each do |hub|
        results_by_hub[hub.name] = []
        results_by_hub[hub.name] += hub.local_charges.map(&:as_json)
        results_by_hub[hub.name] += hub.customs_fees.map(&:as_json)
      end
      results_by_hub
    end

    def local_charges_header_test
      %w(EFFECTIVE_DATE EXPIRATION_DATE
      DESTINATION SERVICE_LEVEL FEE MOT
      FEE_CODE LOAD_TYPE DIRECTION CURRENCY
      RATE_BASIS TON CBM KG ITEM SHIPMENT
      BILL CONTAINER MINIMUM WM RANGE_MIN RANGE_MAX)
    end

    def worksheet_builder(options, range_fee=nil)
      worksheet = write_to_sheet(options[:worksheet], options[:row], options[:start], options[:data])
      if range_fee
        worksheet_conditional_builder(worksheet,  options[:row], options[:fee], range_fee)
      else
        worksheet_conditional_builder(worksheet,  options[:row], options[:fee])
      end
    end

    def worksheet_conditional_builder(worksheet,  row, fee, range_fee=nil)
      case fee[:rate_basis]
      when "PER_CONTAINER"
        worksheet.write(row, 17, fee[:value])
      when "PER_ITEM"
        worksheet.write(row, 14, fee[:value])
      when "PER_BILL"
        worksheet.write(row, 16, fee[:value])
      when "PER_SHIPMENT"
        worksheet.write(row, 15, fee[:value])
      when "PER_CBM_TON"
        worksheet.write(row, 11, fee[:ton])
        worksheet.write(row, 12, fee[:cbm])
        worksheet.write(row, 18, fee[:min])
      when "PER_CBM_KG"
        worksheet.write(row, 13, fee[:kg])
        worksheet.write(row, 12, fee[:cbm])
        worksheet.write(row, 18, fee[:min])
      when "PER_WM"
        if range_fee
          worksheet.write(row, 19, range_fee[:rate])
          worksheet.write(row, 18, fee[:min])
        else
          worksheet.write(row, 19, fee[:value])
        end
      when "PER_KG"
        if range_fee
          worksheet.write(row, 13, range_fee[:rate])
        else
          worksheet.write(row, 13, fee[:kg])
        end
        worksheet.write(row, 18, fee[:min])
      end
      if range_fee
        worksheet.write(row, 20, range_fee[:min])
        worksheet.write(row, 21, range_fee[:max])
      end
      worksheet
    end
  end
end
