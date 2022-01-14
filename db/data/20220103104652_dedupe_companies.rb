# frozen_string_literal: true

class DedupeCompanies < ActiveRecord::Migration[5.2]
  def up
    DedupeCompaniesWorker.perform_async
  end
end
