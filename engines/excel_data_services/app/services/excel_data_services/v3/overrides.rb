# frozen_string_literal: true

module ExcelDataServices
  module V3
    Overrides = Struct.new(:group_id, :document_id, keyword_init: true) do
      def data
        {
          "group_id" => group_id,
          "document_id" => document_id,
          "organization_id" => Organizations.current_id
        }.compact
      end
    end
  end
end
