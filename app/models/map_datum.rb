# frozen_string_literal: true

class MapDatum < ApplicationRecord
  belongs_to :itinerary
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  belongs_to :organization, class_name: 'Organizations::Organization'

  def self.create_all_from_itineraries
    Itinerary.all.each do |itinerary|
      routes_data = itinerary.routes
      routes_data.each do |route_data|
        route_data[:organization_id] = itinerary.organization_id
        itinerary.map_data.find_or_create_by!(route_data)
      end
    end
  end
end

# == Schema Information
#
# Table name: map_data
#
#  id              :bigint           not null, primary key
#  destination     :decimal(, )      default([]), is an Array
#  geo_json        :jsonb
#  line            :jsonb
#  origin          :decimal(, )      default([]), is an Array
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  itinerary_id    :string
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_map_data_on_organization_id  (organization_id)
#  index_map_data_on_sandbox_id       (sandbox_id)
#  index_map_data_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
