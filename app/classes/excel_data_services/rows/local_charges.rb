# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class LocalCharges < Base
      def counterpart_hub_name
        @counterpart_hub_name ||= data[:counterpart_hub_name]
      end

      def fees
        @fees ||= data[:fees]
      end

      def hub_name
        @hub_name ||= data[:hub_name]
      end

      def internal
        @internal ||= data[:internal].to_s.casecmp('x').zero?
      end
    end
  end
end
