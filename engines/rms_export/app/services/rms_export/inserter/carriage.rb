# frozen_string_literal: true

require 'csv'

module RmsExport
  module Inserter
    class Carriage < RmsExport::Inserter::Base
      attr_reader :sheet, :row, :headers, :carrier, :line_service, :route
    end
  end
end
