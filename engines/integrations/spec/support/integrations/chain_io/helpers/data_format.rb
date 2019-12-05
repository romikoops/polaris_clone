# frozen_string_literal: true

module Integrations
  module ChainIo
    module DataFormat
      PATH = File.expand_path('../data/format.json', __dir__)

      def json_format
        file = File.read(PATH)
        @json = JSON.parse(file)
      end
    end
  end
end
