# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class Base
      WillBeRefactoredRestructuringError = Class.new(StandardError)

      def self.append_hub_suffix(name, mot)
        name + ' ' + { 'ocean' => 'Port',
                       'air' => 'Airport',
                       'rail' => 'Railyard',
                       'truck' => 'Depot' }[mot]
      end
    end
  end
end
