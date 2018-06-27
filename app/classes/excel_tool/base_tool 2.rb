module ExcelTool
  class BaseTool
    attr_reader :results, :stats, :hub, :tenant, :xlsx, :hub_id

    def initialize(args = { _user: current_user })
      params = args[:params]
      @stats = _stats
      @results = _results
      @hub_id = args[:hub_id]
      @hub = Hub.find(@hub_id)
      @xlsx = open_file(params["xlsx"])
      post_initialize(args)
    end

    protected
    
    def post_initialize(args)
      nil
    end

    def _stats
      {
        type: "trucking",
        trucking_hubs: {
          number_updated: 0,
          number_created: 0
        },
        trucking_queries: {
          number_updated: 0,
          number_created: 0
        },
        trucking_pricings: {
          number_updated: 0,
          number_created: 0
        },
        trucking_destinations: {
          number_updated: 0,
          number_created: 0
        }
      }
    end

    def _results
      {
        trucking_hubs: [],
        trucking_queries: [],
        trucking_pricings: [],
        trucking_destinations: []
      }
    end

    def open_file(file)
      Roo::Spreadsheet.open(file)
    end

    def uuid
      SecureRandom.uuid
    end
  end
end
