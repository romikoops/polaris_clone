# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class ModeOfTransportType < ExcelDataServices::Validators::TypeValidity::Types::Base
          MOTS = Legacy::Itinerary::MODES_OF_TRANSPORT + ["truck_carriage"]

          def valid?
            case value
            when String
              MOTS.include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
