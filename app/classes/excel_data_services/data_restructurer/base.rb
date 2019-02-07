# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class Base
      WillBeRefactoredRestructuringError = Class.new(StandardError)

      def self.append_hub_suffix(name, mot)
        name + ' ' + case mot
                     when 'ocean' then 'Port'
                     when 'air'   then 'Airport'
                     when 'rail'  then 'Railyard'
                     when 'truck' then 'Depot'
                     end
      end
    end
  end
end
