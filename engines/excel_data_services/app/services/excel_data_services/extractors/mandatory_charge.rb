# frozen_string_literal: true

module ExcelDataServices
  module Extractors
    class MandatoryCharge < ExcelDataServices::Extractors::Base
      def frame_data
        Legacy::MandatoryCharge.all
          .select("mandatory_charges.id as mandatory_charge_id, import_charges, export_charges, pre_carriage, on_carriage")
      end

      def join_arguments
        {
          "import_charges" => "import_charges",
          "export_charges" => "export_charges",
          "pre_carriage" => "pre_carriage",
          "on_carriage" => "on_carriage"
        }
      end

      def frame_types
        {
          "mandatory_charge_id" => :object,
          "import_charges" => :bool,
          "export_charges" => :bool,
          "pre_carriage" => :bool,
          "on_carriage" => :bool
        }.merge(
          ExcelDataServices::DataFrames::DataProviders::Hubs::Hubs.column_types
        )
      end
    end
  end
end
