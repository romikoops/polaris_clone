# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    module DataRestructurer
      module ChargeCategories
        MissingValuesForRateBasisError = Class.new(ExcelDataServices::FileParser::Base::ParsingError)

        private

        def build_charge_params(data)
          all_charge_params = []
          data.values.each do |per_sheet_values|
            all_charge_params << per_sheet_values[:rows_data]
          end
          all_charge_params.flatten
        end

        def restructure_data(data)
          build_charge_params(data)
        end
      end
    end
  end
end
