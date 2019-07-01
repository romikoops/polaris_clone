# frozen_string_literal: true

module ExcelTool
  class OverwriteSchedulesByItinerary < ExcelTool::BaseTool
    attr_reader :first_sheet, :schedules, :itinerary, :_user

    def perform
      overwrite_schedules_by_itinerary
    end

    private

    def overwrite_schedules_by_itinerary
      schedules.each do |row|
        update_stats_result_hashes(row)
      end

      { results: results, stats: stats }
    end

    def post_initialize(args)
      params = args[:params]
      @first_sheet = xlsx.sheet(xlsx.sheets.first)
      @schedules = _schedules
      @itinerary = params['itinerary']
      @user = args[:_user]
      @sandbox = args[:sandbox]
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

    def _schedules
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

    def update_stats_result_hashes(row)
      tenant_vehicle = find_or_creat_tenant_vehicle(row)
      startDate = row[:etd]
      endDate = row[:eta]
      stops = itinerary.stops.order(:index)

      if itinerary
        generator_results = itinerary.generate_schedules_from_sheet(
          stops: stops,
          start_date: startDate,
          end_date: endDate,
          tenant_vehicle_id: tenant_vehicle.vehicle_id,
          closing_date: row[:closing_date],
          vessel: row[:vessel],
          voyage_code: row[:voyage_code],
          load_type: row[:load_type],
          sandbox: @sandbox
        )
        push_results(generator_results)
        push_stats(generator_results)
      else
        raise 'Route cannot be found!'
      end
    end

    def push_results(generator_results)
      results[:trips] = generator_results[:trips]
      results[:layovers] = generator_results[:layovers]
    end

    def push_stats(generator_results)
      stats[:trips][:number_created] = generator_results[:trips].count
      stats[:layovers][:number_created] = generator_results[:layovers].count
    end

    def find_or_creat_tenant_vehicle(row)
      service_level = row[:service_level] || 'standard'
      tv = TenantVehicle.find_by(
        tenant_id: @user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name: row[:service_level],
        sandbox: @sandbox,
        carrier: Carrier.find_by(name: row[:carrier])
      )
      tv ||= TenantVehicle.find_by(
        tenant_id: @user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        sandbox: @sandbox,
        name: row[:service_level]
      )
      tv ||= Vehicle.create_from_name(
        name: service_level,
        mot: itinerary.mode_of_transport,
        tenant_id: @user.tenant_id,
        carrier: row[:carrier],
        sandbox: @sandbox
      )
      tv
    end
  end
end
