# frozen_string_literal: true

class DedupeChargeCategories < ActiveRecord::Migration[5.2]
  def up
    DedupeChargeCategoriesWorker.perform_async
  end
end
