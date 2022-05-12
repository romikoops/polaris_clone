# frozen_string_literal: true

module ExcelDataServices
  module V4
    class Processor
      include ActiveStorage::Downloading

      attr_reader :blob

      def initialize(blob:)
        @blob = blob
      end

      def process
        Tempfile.create(["", blob.filename.extension_with_delimiter]) do |file|
          file.binmode
          file.write(blob.download)
          file.rewind

          yield file
        end
      end
    end
  end
end
