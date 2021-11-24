# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class MandatoryCharge < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Legacy::MandatoryCharge.select("mandatory_charges.id as mandatory_charge_id, import_charges, export_charges, pre_carriage, on_carriage")
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
          }
        end
      end
    end
  end
end
