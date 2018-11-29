# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    module Custom
      module Schryver
        ###
        # Currently, the "standard" DatabaseInserter::OceanFcl is modeled after the Schryver data sheet.
        # In the future, put Schryver specific stuff in here, and rather inherit from the Base like so:
        # `class OceanFcl < DatabaseInserter::Base`
        ###

        class OceanFcl < DatabaseInserter::OceanFcl
        end
      end
    end
  end
end
