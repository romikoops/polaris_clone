# frozen_string_literal: true
class QuotationsMigrateCreatorToPolymorphic < ActiveRecord::Migration[5.2]
  def up
    Quotations::QuotationsMigrateCreatorToPolymorphicWorker.perform_async
  end
end
