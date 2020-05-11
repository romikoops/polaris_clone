# frozen_string_literal: true

class RenameUnusedModels < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_index :geometries, name: 'index_geometries_on_name_1_and_name_2_and_name_3_and_name_4'
      rename_table :geometries, 'geometries_20200504'
      rename_table :hub_truckings, 'hub_truckings_20200504'
      rename_table :hub_truck_type_availabilities, 'hub_truck_type_availabilities_20200504'
      rename_table :truck_type_availabilities, 'truck_type_availabilities_20200504'
      rename_table :trucking_pricings, 'trucking_pricings_20200504'
      rename_table :trucking_destinations, 'trucking_destinations_20200504'
      rename_table :trucking_pricing_scopes, 'trucking_pricing_scopes_20200504'
      rename_table :contents, 'contents_20200504'
      rename_table :documents, 'documents_20200504'
      rename_table :couriers, 'couriers_20200504'
      rename_table :mot_scopes, 'mot_scopes_20200504'
      rename_table :locations, 'locations_20200504'
      rename_table :optin_statuses, 'optin_statuses_20200504'
      rename_table :pricings, 'pricings_20200504'
      remove_index :pricing_details, name: 'index_pricing_details_on_priceable_type_and_priceable_id'
      rename_table :pricing_details, 'pricing_details_20200504'
      rename_table :pricing_requests, 'pricing_requests_20200504'
      rename_table :pricing_exceptions, 'pricing_exceptions_20200504'
      rename_table :transport_categories, 'transport_categories_20200504'
    end
  end
end
