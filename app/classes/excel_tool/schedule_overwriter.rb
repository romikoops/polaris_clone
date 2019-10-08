# frozen_string_literal: true

module ExcelTool
  class ScheduleOverwriter < ExcelTool::BaseTool
    attr_reader :first_sheet, :mot, :user
    def post_initialize(args)
      params = args[:params]
      @mot = args[:mot]
      @first_sheet = xlsx.sheet(xlsx.sheets.first)
      @user = args[:_user]
      @sandbox = args[:sandbox]
    end

    def perform
      overwrite_all_schedules
    end

    private

    def overwrite_all_schedules
      schedules.each do |row|
        itinerary = find_itinerary(row)

        next unless itinerary

        if itinerary
          update_results_and_stats_hashes(row, itinerary)
        else
          raise 'Route cannot be found!'
        end
      end
      { results: results, stats: stats }
    end

    def create_tenant_vehicle(row, itinerary)
      service_level = row[:service_level] || 'standard'
      Legacy::Vehicle.create_from_name(
        name: service_level,
        mot: itinerary.mode_of_transport,
        tenant_id: @user.tenant_id,
        carrier_name: row[:carrier],
        sandbox: @sandbox
      )
    end

    def _stats
      {
        type: 'schedules',
        layovers: {
          number_updated: 0,
          number_created: 0
        },
        trips: {
          number_updated: 0,
          number_created: 0
        }
      }
    end

    def _results
      {
        layovers: [],
        trips: []
      }
    end

    def schedules
      first_sheet.parse(
        vessel: 'VESSEL',
        voyage_code: 'VOYAGE_CODE',
        from: 'FROM',
        to: 'TO',
        closing_date: 'CLOSING_DATE',
        eta: 'ETA',
        etd: 'ETD',
        service_level: 'SERVICE_LEVEL',
        carrier: 'CARRIER',
        load_type: 'LOAD_TYPE'
      )
    end

    def find_itinerary(row)
      itinerary_from = row[:from].split(' ').map(&:capitalize).join(' ')
      itinerary_to = row[:to].split(' ').map(&:capitalize).join(' ')
      Legacy::Itinerary.find_by(
        name: "#{itinerary_from} - #{itinerary_to}",
        mode_of_transport: mot,
        tenant_id: @user.tenant_id,
        sandbox: @sandbox
      )
    end

    def find_or_create_tenant_vehicle(row, itinerary)
      tenant_vehicle = find_tenant_vehicle(row, itinerary)
      tenant_vehicle
    end

    def find_tenant_vehicle(row, itinerary)
      service_level = row[:service_level] || 'standard'
      tv = Legacy::TenantVehicle.find_by(
        tenant_id: @user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name: row[:service_level],
        carrier: Carrier.find_by(name: row[:carrier]),
        sandbox: @sandbox
      )
      tv ||= Legacy::TenantVehicle.find_by(
        tenant_id: @user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name: row[:service_level],
        sandbox: @sandbox
      )
      tv ||= Legacy::Vehicle.create_from_name(
        name: service_level,
        mot: itinerary.mode_of_transport,
        tenant_id: @user.tenant_id,
        carrier_name: row[:carrier],
        sandbox: @sandbox
      )

      tv
    end

    def update_results_and_stats_hashes(row, itinerary)
      start_date = row[:etd]
      end_date = row[:eta]
      stops = itinerary.stops.order(:index)

      tenant_vehicle_id = find_or_create_tenant_vehicle(row, itinerary).id
      generator_results = itinerary.generate_schedules_from_sheet(
        stops: stops,
        start_date: start_date,
        end_date: end_date,
        tenant_vehicle_id: tenant_vehicle_id,
        closing_date: row[:closing_date],
        vessel: row[:vessel],
        voyage_code: row[:voyage_code],
        load_type: row[:load_type],
        sandbox: @sandbox
      )
      results[:trips] = generator_results[:trips]
      results[:layovers] = generator_results[:layovers]
      stats[:trips][:number_created] = generator_results[:trips].count
      stats[:layovers][:number_created] = generator_results[:layovers].count
    end
  end
end
