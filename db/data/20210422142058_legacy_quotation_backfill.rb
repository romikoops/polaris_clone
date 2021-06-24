# frozen_string_literal: true

class LegacyQuotationBackfill < ActiveRecord::Migration[5.2]
  def up
    LegacyQuotationBackfillWorker.perform_async
  end
end
