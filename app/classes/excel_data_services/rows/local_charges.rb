# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class LocalCharges < ExcelDataServices::Rows::Base
      def counterpart_country
        @counterpart_country ||= data[:counterpart_country]
      end

      def counterpart_hub
        @counterpart_hub ||= data[:counterpart_hub]
      end

      def counterpart_hub_locode
        @counterpart_hub_locode ||= data[:counterpart_locode]
      end

      def fees
        @fees ||= data[:fees]
      end

      def internal
        @internal ||= data[:internal]
      end

      def hub
        @hub ||= data[:hub]
      end

      def hub_country
        @hub_country ||= data[:country]
      end

      def hub_locode
        @hub_locode ||= data[:locode]
      end
    end
  end
end
