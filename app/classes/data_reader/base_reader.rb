# frozen_string_literal: true

module DataReader
  class BaseReader
    attr_reader :xlsx, :sheets_data

    def initialize(args = { user: current_user })
      # FOR DEBUGGING:
      # In console run e.g. `x = DataReader::OceanLclReader.new({})`
      path = Rails.root.join('app', 'classes', 'data_reader', 'test.xlsx').to_s
      args = args.merge(path: path)

      @xlsx = open_spreadsheet_file(args[:path])
      @sheets_data = {}
      @stats = {}
      post_initialize
    end

    def perform
      raise NotImplementedError, "This method must be implemented in #{self.class.name} "
    end

    def stats
      @stats.merge!(local_stats)
    end

    private

    def parse_headers(header_row)
      header_row.map! do |el|
        el.downcase!
        el.gsub!(/\/+/, '__') # double underscore instead of slash
        el.gsub!(/[^a-z0-9\-]+/, '_') # underscore instead of unwanted characters
        el.to_sym
      end
    end

    def post_initialize
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def local_stats
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def open_spreadsheet_file(path)
      Roo::Spreadsheet.open(path)
    end
  end
end
