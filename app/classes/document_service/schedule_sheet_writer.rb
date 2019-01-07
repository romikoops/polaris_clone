# frozen_string_literal: true

module DocumentService
  class ScheduleSheetWriter
    include AwsConfig
    include WritingTool
    attr_reader :tenant, :options, :trips, :worksheet, :directory, :workbook, :worksheet, :itinerary, :filename

    def initialize(options)
      @options = options
      @tenant = tenant_finder(options[:tenant_id])
      pre_initialize
      @directory = "tmp/#{@filename}"
      workbook_hash    = add_worksheet_to_workbook(create_workbook(@directory), header_values)
      @workbook        = workbook_hash[:workbook]
      @worksheet       = workbook_hash[:worksheet]
    end

    def perform
      write_schedule_to_sheet
      workbook.close
      write_to_aws(directory, tenant, filename, "schedules_sheet")
    end

    private

    def pre_initialize
      if options[:mode_of_transport] && !options[:itinerary_id]
        @trips = find_trip
        @filename = build_file_name
      elsif options[:itinerary_id]
        @itinerary = find_itinerary
        @trips = @itinerary.trips.order(:start_date)
        @filename = build_file_name
      else
        @trips = find_trip
        @filename = build_file_name
      end
    end

    def find_trip
      if options[:mode_of_transport] && !options[:itinerary_id]
        Trip
          .joins("INNER JOIN itineraries ON trips.itinerary_id = itineraries.id AND itineraries.mode_of_transport = '#{options[:mode_of_transport]}' AND itineraries.tenant_id = #{options[:tenant_id]}")
          .where("start_date > ? AND end_date < ?", Date.today, Date.today + 3.months)
          .order(:start_date)
      else
        Trip
          .joins("INNER JOIN itineraries ON trips.itinerary_id = itineraries.id AND itineraries.tenant_id = #{options[:tenant_id]}")
          .where("start_date > ? AND end_date < ?", Date.today, Date.today + 3.months)
          .order(:start_date)
      end
    end

    def find_itinerary
      Itinerary.find(options[:itinerary_id])
    end

    def build_file_name
      if options[:mode_of_transport] && !options[:itinerary_id]
        "#{options[:mode_of_transport]}_schedules_#{formated_date}.xlsx"
      elsif options[:itinerary_id]
        "#{itinerary.name}_schedules_#{formated_date}.xlsx"
      else
        "#{tenant.name}_schedules_#{formated_date}.xlsx"
      end
    end

    def header_values
      %w(FROM TO CLOSING_DATE ETD ETA TRANSIT_TIME SERVICE_LEVEL CARRIER MODE_OF_TRANSPORT VESSEL VOYAGE_CODE)
    end

    def write_schedule_data(row, layovers, trip)
      diff = (layovers.last.eta - layovers.first.etd) / 86_400
      worksheet.write(row, 0, layovers.first.stop.hub.nexus.name)
      worksheet.write(row, 1, layovers.last.stop.hub.nexus.name)
      worksheet.write(row, 2, layovers.first.closing_date)
      worksheet.write(row, 3, layovers.first.etd)
      worksheet.write(row, 4, layovers.last.eta)
      worksheet.write(row, 5, diff)
      worksheet.write(row, 6, trip.tenant_vehicle.name)
      worksheet.write(row, 7, trip.tenant_vehicle&.carrier&.name)
      worksheet.write(row, 8, trip.itinerary.mode_of_transport)
      worksheet.write(row, 9, trip.vessel)
      worksheet.write(row, 10, trip.voyage_code)
    end

    def write_schedule_to_sheet
      row = 1
      trips.each do |trip|
        layovers = trip.layovers.order(:stop_index)
        next if layovers.length < 2
        write_schedule_data(row, layovers, trip)
        row += 1
      end
    end
  end 
end
