# frozen_string_literal: true

require "nokogiri"
require "zip/filesystem"
require "roo/link"
require "roo/tempdir"
require "roo/utils"
require "forwardable"
require "set"

module Roo
  class ExcelxMoney < ::Roo::Excelx
    def initialize(filename_or_stream, options = {})
      filename_or_stream = filename_or_stream.respond_to?(:path) ? filename_or_stream.path : filename_or_stream

      super(filename_or_stream, options)

      sheet_options = {}
      sheet_options[:expand_merged_ranges] = (options[:expand_merged_ranges] || false)
      sheet_options[:no_hyperlinks] = (options[:no_hyperlinks] || false)
      sheet_options[:empty_cell] = (options[:empty_cell] || false)

      @sheet_names.each_with_index do |sheet_name, n|
        @sheets_by_name[sheet_name] = @sheets[n] = ::Roo::ExcelxMoney::Sheet.new(sheet_name, @shared, n, sheet_options)
      end
    rescue
      self.class.finalize_tempdirs(object_id)
      raise
    end
  end
end

require_relative "sheet_money"
