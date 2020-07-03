# frozen_string_literal: true

class MaxDimensionsBundle < Legacy::MaxDimensionsBundle
end

# == Schema Information
#
# Table name: max_dimensions_bundles
#
#  id                :bigint           not null, primary key
#  aggregate         :boolean
#  cargo_class       :string
#  chargeable_weight :decimal(, )
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  height            :decimal(, )
#  length            :decimal(, )
#  mode_of_transport :string
#  payload_in_kg     :decimal(, )
#  volume            :decimal(, )      default(1000.0)
#  width             :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :bigint
#  itinerary_id      :bigint
#  organization_id   :uuid
#  sandbox_id        :uuid
#  tenant_id         :integer
#  tenant_vehicle_id :bigint
#
# Indexes
#
#  index_max_dimensions_bundles_on_cargo_class        (cargo_class)
#  index_max_dimensions_bundles_on_carrier_id         (carrier_id)
#  index_max_dimensions_bundles_on_itinerary_id       (itinerary_id)
#  index_max_dimensions_bundles_on_mode_of_transport  (mode_of_transport)
#  index_max_dimensions_bundles_on_organization_id    (organization_id)
#  index_max_dimensions_bundles_on_sandbox_id         (sandbox_id)
#  index_max_dimensions_bundles_on_tenant_id          (tenant_id)
#  index_max_dimensions_bundles_on_tenant_vehicle_id  (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
