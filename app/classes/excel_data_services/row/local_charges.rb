# frozen_string_literal: true

module ExcelDataServices
  module Row
    class LocalCharges < Base
      def hub_id
        @hub_id ||= data[:hub_id]
      end

      def counterpart_hub_id
        @counterpart_hub_id ||= data[:counterpart_hub_id]
      end
    end
  end
end
