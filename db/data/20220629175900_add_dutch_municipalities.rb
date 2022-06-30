# frozen_string_literal: true

class AddDutchMunicipalities < ActiveRecord::Migration[5.2]
  def up
    AddDutchMunicipalitiesWorker.perform_async
  end
end
