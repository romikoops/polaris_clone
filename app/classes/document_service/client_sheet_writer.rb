# frozen_string_literal: true

module DocumentService
  class ClientSheetWriter
    include AwsConfig
    include WritingTool
    attr_reader :tenant, :hubs, :filename, :directory, :workbook, :worksheet

    def initialize(options)
      @tenant = Tenant.find(options[:tenant_id])
      @hubs = @tenant.hubs
      @filename = "schedules_#{formated_date}.xlsx"
      @directory = "tmp/#{@filename}"
      workbook_hash = add_worksheet_to_workbook(create_workbook(@directory), header_values)
      @workbook = workbook_hash[:workbook]
      @worksheet = workbook_hash[:worksheet]
    end

    def perform
      write_clients_to_sheet
    end

    private

    def header_values
      %w(FROM TO CLOSING_DATE ETD ETA TRANSIT_TIME SERVICE_LEVEL MODE_OF_TRANSPORT VESSEL VOYAGE_CODE)
    end

    def write_client_data(row, layovers, trip)
      diff = (layovers.last.eta - layovers.first.etd) / 86_400
      worksheet.write(row, 0, layovers.first.stop.hub.nexus.name)
      worksheet.write(row, 1, layovers.last.stop.hub.nexus.name)
      worksheet.write(row, 2, layovers.first.closing_date)
      worksheet.write(row, 3, layovers.first.etd)
      worksheet.write(row, 4, layovers.last.eta)
      worksheet.write(row, 5, diff)
      worksheet.write(row, 6, trip.vehicle.name)
      worksheet.write(row, 7, trip.itinerary.mode_of_transport)
      worksheet.write(row, 8, trip.vessel)
      worksheet.write(row, 9, trip.voyage_code)
    end

    def write_clients_to_sheet
      row = 1
      trips.each do |trip|
        layovers = trip.layovers.order(:stop_index)
        next if layovers.length < 2

        write_client_data(row, layovers, trip)
        row += 1
      end
      workbook.close
      write_to_aws(directory, tenant, filename, 'schedules_sheet')
    end
  end
end
