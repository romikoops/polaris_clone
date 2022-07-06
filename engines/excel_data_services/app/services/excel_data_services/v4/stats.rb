# frozen_string_literal: true

module ExcelDataServices
  module V4
    Stats = Struct.new(:type, :created, :failed, :errors, :warnings, keyword_init: true) do
      def mergeable_stats
        { type => as_json.slice("created", "failed") }
      end
    end
  end
end
