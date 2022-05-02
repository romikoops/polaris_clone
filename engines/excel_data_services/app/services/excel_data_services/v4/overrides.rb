# frozen_string_literal: true

module ExcelDataServices
  module V4
    Overrides = Struct.new(:group_id, :document_id, :hub_id, keyword_init: true) do
      def data
        {
          "group_id" => group_id,
          "hub_id" => hub_id,
          "document_id" => document_id,
          "organization_id" => Organizations.current_id
        }.compact
      end
    end
  end
end
