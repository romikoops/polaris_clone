# frozen_string_literal: true

module DocumentService
  class ScheduleSheetWriter
    include AwsConfig
    include WritingTool
    attr_reader :organization, :options, :trips, :worksheet, :directory, :workbook, :worksheet, :itinerary, :filename

    def initialize(options)
      @options = options
      @organization = Organizations::Organization.find(options[:organization_id])
      @organization_theme = @organization.theme
      pre_initialize
      @directory = "tmp/#{@filename}"
      workbook_hash    = add_worksheet_to_workbook(create_workbook(@directory), header_values)
      @workbook        = workbook_hash[:workbook]
      @worksheet       = workbook_hash[:worksheet]
    end

    def perform
      write_schedule_to_sheet
      workbook.close
      write_to_aws(directory, organization, filename, 'schedules_sheet')
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
      @trips = @trips.includes(:layovers)
    end

    def find_trip
      # dates limited for performance reasons
      start_date = Date.today
      end_date = Date.today + 3.months
      # variables hardcoded until params are sent from front end
      if options[:mode_of_transport] && !options[:itinerary_id]
        Trip
          .joins("INNER JOIN itineraries ON trips.itinerary_id = itineraries.id 
            AND itineraries.mode_of_transport = '#{options[:mode_of_transport]}' 
            AND itineraries.organization_id = '#{options[:organization_id]}'"
          )
          .where('start_date > ? AND end_date < ?', start_date, end_date)
          .order(:start_date)
      else
        Trip
          .joins("INNER JOIN itineraries ON trips.itinerary_id = itineraries.id 
            AND itineraries.organization_id = '#{options[:organization_id]}'"
          )
          .where('start_date > ? AND end_date < ?', start_date, end_date)
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
        "#{@organization_theme.name}_schedules_#{formated_date}.xlsx"
      end
    end

    def header_values
      %w(FROM TO CLOSING_DATE ETD ETA TRANSIT_TIME SERVICE_LEVEL CARRIER MODE_OF_TRANSPORT VESSEL VOYAGE_CODE LOAD_TYPE)
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
      worksheet.write(row, 11, trip.load_type)
    end

    def write_schedule_to_sheet
      row = 1
      trips.each do |trip|
        layovers = trip.layovers.sort_by(&:stop_index)
        next if layovers.length < 2

        write_schedule_data(row, layovers, trip)
        row += 1
      end
    end
  end
end
