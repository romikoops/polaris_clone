# frozen_string_literal: true

class LoadGermanyMunicipalityGeoData < ActiveRecord::Migration[5.2]
  def up
    LoadGermanyMunicipalityGeoDataWorker.perform_async
  end
end
