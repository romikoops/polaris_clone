# frozen_string_literal: true

module ExcelDataServices
  module V3
    Stats = Struct.new(:type, :created, :failed, :errors, :exception, keyword_init: true) do
      def mergeable_stats
        { type => as_json.slice("created", "failed") }
      end
    end
  end
end
