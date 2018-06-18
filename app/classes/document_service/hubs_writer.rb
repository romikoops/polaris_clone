# frozen_string_literal: true

module DocumentService
  class HubsWriter
    include WritingTool
    attr_reader :tenant, :hubs, :filename, :directory, :workbook, :worksheet
    
    def initialize(options)
      @tenant = Tenant.find(options[:tenant_id])
      @hubs = @tenant.hubs
      @filename = "hubs_#{formated_date}.xlsx"
      @directory = "tmp/#{@filename}"
      workbook_hash = add_worksheet_to_workbook(create_workbook(@directory), header_values)
      @workbook = workbook_hash[:workbook]
      @worksheet = workbook_hash[:worksheet]
    end

    def perform
      row = 1
      hubs.each do |hub|
        write_hub_to_sheet(row, hub)
        row += 1
      end
      workbook.close
      write_to_aws(directory, tenant, filename, "hubs_sheet")
    end

    def write_hub_to_sheet(row, hub)
      worksheet.write(row, 0, hub.hub_status)
      worksheet.write(row, 1, hub.hub_type)
      worksheet.write(row, 2, hub.nexus.name)
      worksheet.write(row, 3, hub.hub_code)
      worksheet.write(row, 4, hub.location.latitude)
      worksheet.write(row, 5, hub.location.longitude)
      worksheet.write(row, 6, hub.location.country.name)
      worksheet.write(row, 7, hub.location.geocoded_address)
    end

    def header_values
      %w(STATUS TYPE NAME CODE LATITUDE LONGITUDE COUNTRY FULL_ADDRESS)
    end
  end
end
