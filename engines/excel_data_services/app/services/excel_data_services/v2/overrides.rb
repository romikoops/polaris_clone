# frozen_string_literal: true

module ExcelDataServices
  module V2
    Overrides = Struct.new(:group_id, :hub_id, keyword_init: true) do
      def frame
        Rover::DataFrame.new([data])
      end

      def data
        {
          "group_id" => group_id,
          "hub_id" => hub_id
        }.compact
      end
    end
  end
end
