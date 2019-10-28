# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class LocalCharges < Base
      def counterpart_hub
        @counterpart_hub ||= data[:counterpart_hub]
      end

      def counterpart_hub_locode
        @counterpart_hub_locode ||= data[:counterpart_hub_locode]
      end

      def fees
        @fees ||= data[:fees]
      end

      def internal
        @internal ||= data[:internal].to_s.casecmp('x').zero?
      end

      def hub
        @hub ||= data[:hub]
      end

      def hub_locode
        @hub_locode ||= data[:hub_locode]
      end
    end
  end
end
