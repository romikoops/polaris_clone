# frozen_string_literal: true

module DocumentService
  class HubsWriter
    include AwsConfig
    include WritingTool
    attr_reader :tenant, :hubs, :filename, :directory, :workbook, :worksheet

    def initialize(options)
      @tenant = Tenant.find(options[:tenant_id])
      @sandbox = options[:sandbox] || false
      @hubs = @tenant.hubs.where(sandbox: @sandbox)
      @filename = "hubs_#{formated_date}.xlsx"
      @directory = "tmp/#{@filename}"
      workbook_hash = add_worksheet_to_workbook(create_workbook(@directory), header_values)
      @workbook = workbook_hash[:workbook]
      @worksheet = workbook_hash[:worksheet]
      @mandatory_charges = @hubs.each_with_object({}) { |hub, r_hash| r_hash[hub.id] = hub.mandatory_charge }
    end

    def perform
      row = 1
      hubs.each do |hub|
        write_hub_to_sheet(row, hub)
        row += 1
      end
      workbook.close
      write_to_aws(directory, tenant, filename, 'hubs_sheet')
    end

    def write_hub_to_sheet(row, hub)
      worksheet.write(row, 0, hub.hub_status)
      worksheet.write(row, 1, hub.hub_type)
      worksheet.write(row, 2, hub.nexus&.name)
      worksheet.write(row, 3, hub.hub_code || hub.nexus&.locode)
      worksheet.write(row, 4, hub.address&.latitude)
      worksheet.write(row, 5, hub.address&.longitude)
      worksheet.write(row, 6, hub.address&.country&.name)
      worksheet.write(row, 7, hub.address&.geocoded_address)
      worksheet.write(row, 8, hub.free_out.to_s)
      worksheet.write(row, 9, @mandatory_charges[hub.id]&.import_charges&.to_s )
      worksheet.write(row, 10, @mandatory_charges[hub.id]&.export_charges&.to_s)
      worksheet.write(row, 11, @mandatory_charges[hub.id]&.pre_carriage&.to_s)
      worksheet.write(row, 12, @mandatory_charges[hub.id]&.on_carriage&.to_s)
      worksheet.write(row, 13, hub.photo)
    end

    def header_values
      %w(STATUS TYPE NAME LOCODE LATITUDE LONGITUDE COUNTRY FULL_ADDRESS FREE_OUT IMPORT_CHARGES EXPORT_CHARGES PRE_CARRIAGE 
        ON_CARRIAGE PHOTO ALTERNATIVE_NAMES)
    end
  end
end
