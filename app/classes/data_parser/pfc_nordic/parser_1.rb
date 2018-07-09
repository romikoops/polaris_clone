# frozen_string_literal: true
module PfcNordic
  class Parser1
    require "roo"
    require "roo-xls" # for legacy '.xls' support
    require 'json'
    attr_reader :data
  
    def initialize(path_to_file)
      xlsx = Roo::Spreadsheet.open(path_to_file)
      @sheet = xlsx.sheet(0)
      @data = {}
    end
  
    def get_country(row_index)
      # Look one row above current one for country name.
      @sheet.row(row_index - 1).first
    end
  
    def row_to_hash(row_index)
      {
        port:     @sheet.cell("B", row_index),
        code:     @sheet.cell("D", row_index),
        rate:     @sheet.cell("F", row_index),
        currency: @sheet.cell("I", row_index),
        minimum:  @sheet.cell("J", row_index),
        basis:    @sheet.cell("K", row_index),
        notes:    @sheet.cell("M", row_index)
      }
    end
  
    def perform
      @sheet.each_with_index do |_row, i|
        row_index = i + 1
  
        # "Hafen" is unique anchor that differentiates the data
        # of the individual countries.
        next unless @sheet.cell("B", row_index) == "Hafen"
  
        country = get_country(row_index)
        row_hashes = []
  
        # Look one row after the current one for actual data rows.
        # Stop iterating when no valid float value for the "Rate" column is found.
        row_index += 1
        row_hash = row_to_hash(row_index)
        while row_hash[:rate].is_a? Float
          row_hashes << row_hash
          row_index += 1
          row_hash = row_to_hash(row_index)
        end
  
        @data[country] = row_hashes
      end
    end
  end
  
end
