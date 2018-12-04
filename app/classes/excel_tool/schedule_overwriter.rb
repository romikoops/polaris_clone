module ExcelTool
  class ScheduleOverwriter < ExcelTool::BaseTool
    attr_reader :first_sheet, :mot, :user
    def post_initialize(args)
      params = args[:params]
      @mot = args[:mot]
      @first_sheet = xlsx.sheet(xlsx.sheets.first)
      @user = args[:_user]
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
          raise "Route cannot be found!"
        end
      end
      { results: results, stats: stats }
    end

    def create_tenant_vehicle(row, itinerary)
      service_level = row[:service_level] ? row[:service_level] : "standard"
      Vehicle.create_from_name(
        service_level, itinerary.mode_of_transport, @user.tenant_id, row[:carrier])
    end

    def _stats
      {
        type:     "schedules",
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

    def schedules
      first_sheet.parse(
        vessel:        "VESSEL",
        voyage_code:   "VOYAGE_CODE",
        from:          "FROM",
        to:            "TO",
        closing_date:  "CLOSING_DATE",
        eta:           "ETA",
        etd:           "ETD",
        service_level: "SERVICE_LEVEL",
        carrier:       'CARRIER'
      )
    end

    def find_itinerary(row)
      @user.tenant.itineraries.find_by(name: "#{row[:from]} - #{row[:to]}", mode_of_transport: mot)
    end

    def find_or_create_tenant_vehicle(row, itinerary)
      tenant_vehicle = find_tenant_vehicle(row, itinerary)
      tenant_vehicle
    end

    def find_tenant_vehicle(row, itinerary)
      service_level = row[:service_level] || 'standard'
      tv = TenantVehicle.find_by(
        tenant_id:         @user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name:              row[:service_level],
        carrier:          Carrier.find_by(name: row[:carrier])
      )
      tv ||= TenantVehicle.find_by(
        tenant_id:         @user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name:              row[:service_level]
      )
      tv ||= Vehicle.create_from_name(service_level, itinerary.mode_of_transport, @user.tenant_id, row[:carrier])
      
      tv
    end

    def update_results_and_stats_hashes(row, itinerary)
      start_date = row[:etd]
      end_date = row[:eta]
      stops = itinerary.stops.order(:index)

      tenant_vehicle_id = find_or_create_tenant_vehicle(row, itinerary).id
      generator_results = itinerary.generate_schedules_from_sheet(stops, start_date,
        end_date, tenant_vehicle_id, row[:closing_date], row[:vessel], row[:voyage_code])
      results[:trips] = generator_results[:trips]
      results[:layovers] = generator_results[:layovers]
      stats[:trips][:number_created] = generator_results[:trips].count
      stats[:layovers][:number_created] = generator_results[:layovers].count
    end
  end
end
