# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Runners
      class State < Struct.new(:file, :frame, :errors, :hub_id, :group_id, :organization_id, keyword_init: true)
      end
    end
  end
end
