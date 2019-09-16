# frozen_string_literal: true

module ExcelTool
  class BaseTool
    attr_reader :results, :stats, :hub, :tenant, :xlsx, :hub_id
    include AwsConfig
    def initialize(args = { _user: current_user })
      params = args[:params].with_indifferent_access
      @stats = _stats
      @results = _results
      
      if args[:hub_id]
        @hub_id = args[:hub_id]
        @hub = Hub.find(@hub_id)
      end

      if params['xlsx']
        @xlsx = open_file(params['xlsx'])
      elsif params['key']
        signed_url = get_file_url(params['key'], 'assets.itsmycargo.com')
        @xlsx = open_file(signed_url)
      end

      post_initialize(args)
    end

    def perform
      raise NotImplementedError, "This method must be implemented in #{self.class.name} "
    end

    protected

    def post_initialize(_args)
      nil
    end

    def _stats
      {
        type: 'trucking'
      }.merge(local_stats)
    end

    def local_stats
      {}
    end

    def _results
      {}
    end

    def open_file(file)
      Roo::Spreadsheet.open(file)
    end

    def uuid
      SecureRandom.uuid
    end

    def debug_message(message)
      puts message
    end

    def set_general_local_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
      if charge[:rate_basis].include? 'RANGE'
        if load_type == 'fcl'
          Container::CARGO_CLASSES.each do |lt|
            set_range_fee(all_charges, charge, lt, direction, tenant_vehicle_id, mot, counterpart_hub_id)
          end
        else
          set_range_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
        end
      else
        set_regular_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
      end
    end

    def set_regular_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, _mot, counterpart_hub_id)
      if load_type == 'fcl'
        Container::CARGO_CLASSES.each do |lt|
          all_charges[counterpart_hub_id][tenant_vehicle_id][direction][lt]['fees'][charge[:key]] = charge
        end
      else
        if !all_charges[counterpart_hub_id] ||
           !all_charges[counterpart_hub_id][tenant_vehicle_id] ||
           !all_charges[counterpart_hub_id][tenant_vehicle_id][direction] ||
           !all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]
        end
        all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]] = charge
      end
      all_charges
    end
  end
end
