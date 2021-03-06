# frozen_string_literal: true

module Legacy
  class TenantVehicle < ApplicationRecord
    self.table_name = "tenant_vehicles"
    TENANT_VEHICLE_MODES_OF_TRANSPORT = (Legacy::Itinerary::MODES_OF_TRANSPORT + ["truck_carriage"]).freeze

    acts_as_paranoid

    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :vehicle, optional: true
    belongs_to :carrier, optional: true
    has_many :pricings, class_name: "Pricings::Pricing"
    has_many :transit_times, class_name: "Legacy::TransitTime", dependent: :destroy

    validates_uniqueness_of :name, scope: [:organization_id, :carrier_id, :mode_of_transport]
    validates :mode_of_transport, inclusion: { in: TENANT_VEHICLE_MODES_OF_TRANSPORT }

    def full_name
      carrier_id ? "#{carrier&.name} - #{name}" : name
    end

    def with_carrier
      as_json(include: {carrier: {only: %i[id name]}})
    end
  end
end

# == Schema Information
#
# Table name: tenant_vehicles
#
#  id                :bigint           not null, primary key
#  carrier_lock      :boolean          default(FALSE)
#  deleted_at        :datetime
#  is_default        :boolean
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :integer
#  organization_id   :uuid
#  sandbox_id        :uuid
#  tenant_id         :integer
#  vehicle_id        :integer
#
# Indexes
#
#  index_tenant_vehicles_on_organization_id  (organization_id)
#  index_tenant_vehicles_on_sandbox_id       (sandbox_id)
#  index_tenant_vehicles_on_tenant_id        (tenant_id)
#  tenant_vehicles_upsert                    (organization_id,name,mode_of_transport,carrier_id) WHERE (deleted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
