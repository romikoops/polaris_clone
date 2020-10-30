# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      class State < Struct.new(:schema, :frame, :errors, :hub_id, :group_id, :organization_id, keyword_init: true)
        def [](key)
          send(key)
        end
      end
    end
  end
end
