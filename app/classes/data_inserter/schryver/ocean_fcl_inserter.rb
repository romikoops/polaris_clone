# frozen_string_literal: true

module DataInserter
  module Schryver
    ###
    # Currently, the "standard" OceanFCLInserter is modeled after the Schryver data sheet.
    # In the future, put Schryver specific stuff in here, and rather inherit from the BaseFclInserter like so:
    # `class OceanFclInserter < DataInserter::BaseInserter`
    ###

    class OceanFclInserter < DataInserter::OceanFclInserter
    end
  end
end
