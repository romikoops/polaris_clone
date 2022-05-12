# frozen_string_literal: true

module ExcelDataServices
  module V4
    class Xml
      attr_reader :document, :xml

      def initialize(document:)
        ExcelDataServices::V4::Processor.new(blob: document.file.blob).process do |file|
          @xml = Hash.from_xml(file.read)
        end
      end
    end
  end
end
