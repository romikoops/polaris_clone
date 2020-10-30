# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Importers
      class Stats < Struct.new(:type, :created, :failed, :errors, keyword_init: true)
        def mergeable_stats
          {type => as_json.slice("created", "failed")}
        end
      end
    end
  end
end
