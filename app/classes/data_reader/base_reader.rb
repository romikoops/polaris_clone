# frozen_string_literal: true

module DataReader
  class BaseReader
    attr_reader :xlsx, :sheets_data

    def initialize(args = { user: current_user })
      # FOR DEBUGGING------------------------------------------
      # In console run e.g. `x = DataReader::OceanLclReader.new({})`
      path = Rails.root.join('app', 'classes', 'data_reader', 'test_LCL.xlsx').to_s
      args = args.merge(path: path)
      # /FOR DEBUGGING-----------------------------------------

      @xlsx = open_spreadsheet_file(args[:path])
      @sheets_data = {}
      @stats = {}
      post_initialize
    end

    def perform
      @xlsx.each_with_pagename do |sheet_name, sheet_data|
        headers = parse_headers(sheet_data.first)
        rows_data = []

        # Parse all but first row
        ((sheet_data.first_row + 1)..sheet_data.last_row).each do |row_index|
          rows_data << build_row_obj(headers, sheet_data.row(row_index))
        end

        @sheets_data.merge!(sheet_name => rows_data)
      end

      @sheets_data
    end

    def stats
      @stats.merge!(local_stats)
    end

    private

    def post_initialize
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def local_stats
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def open_spreadsheet_file(path)
      Roo::Spreadsheet.open(path)
    end

    def parse_headers(header_row)
      header_row.map! do |el|
        el.downcase!
        el.gsub!(/[^a-z0-9\-\/\_]+/, '_') # underscore instead of unwanted characters
        el.gsub!(/\/+/, '__') # double underscore instead of slash
        el.to_sym
      end
    end

    def parse_row_data(row_data)
      # TODO: More sanitization
      row_data.map! { |el| el.is_a?(String) ? el.strip : el }
    end
  end
end
