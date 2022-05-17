# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class Importer
        # The Importer class takes the configuration from the config file and triggers the Import class with the arguments provided and teh current State object
        attr_reader :model, :options

        def initialize(model:, options:)
          @model = model
          @options = options
        end

        def state(state:)
          state.stats << ExcelDataServices::V4::Import.import(model: model, data: state.insertable_data, type: model.name.demodulize.underscore, options: options)
          state
        end
      end
    end
  end
end
