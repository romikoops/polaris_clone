# frozen_string_literal: true

module ExcelDataServices
  module V4
    class HashFromXml
      attr_reader :document, :xml

      def initialize(document:)
        @document = document
        Processor.new(blob: document.file.blob).process do |file|
          @xml = Hash.from_xml(file.read)
        end
      end
    end
  end
end
