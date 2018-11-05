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
      @_user = args[:_user]
    end

    def _stats
      {
        type:     'schedules',
        layovers: {
          number_updated: 0,
          number_created: 0
        },
        trips:    {
          number_updated: 0,
          number_created: 0
        }
      }
    end

    def _results
      {
        layovers: [],
        trips:    []
      }
    end

    def _schedules
      first_sheet.parse(
        vessel:        'VESSEL',
        voyage_code:   'VOYAGE_CODE',
        from:          'FROM',
        to:            'TO',
        closing_date:  'CLOSING_DATE',
        eta:           'ETA',
        etd:           'ETD',
        service_level: 'SERVICE_LEVEL',
        carrier:       'CARRIER'
      )
    end

    def update_stats_result_hashes(row)
      tenant_vehicle = find_or_creat_tenant_vehicle(row)
      startDate = row[:etd]
      endDate = row[:eta]
      stops = itinerary.stops.order(:index)

      if itinerary
        generator_results = itinerary.generate_schedules_from_sheet(
          stops, startDate, endDate, tenant_vehicle.vehicle_id,
          row[:closing_date], row[:vessel], row[:voyage_code]
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
        tenant_id: _user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name: row[:service_level],
        carrier: Carrier.find_by(name: row[:carrier])
      )
      tv ||= TenantVehicle.find_by(
        tenant_id: _user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name: row[:service_level]
      )
      tv ||= Vehicle.create_from_name(service_level, itinerary.mode_of_transport, _user.tenant_id, row[:carrier])
      tv
    end
  end
end
