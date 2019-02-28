# frozen_string_literal: true

module ExcelDataServices
  module Row
    class LocalCharges < Base
      def hub_name
        @hub_name ||= data[:hub_name]
      end

      def counterpart_hub_name
        @counterpart_hub_name ||= data[:counterpart_hub_name]
      end
    end
  end
end
