# frozen_string_literal: true

class LocalCharge < Legacy::LocalCharge
end

# == Schema Information
#
# Table name: local_charges
#
#  id                 :bigint           not null, primary key
#  dangerous          :boolean          default(FALSE)
#  deleted_at         :datetime
#  direction          :string
#  effective_date     :datetime
#  expiration_date    :datetime
#  fees               :jsonb
#  internal           :boolean          default(FALSE)
#  load_type          :string
#  metadata           :jsonb
#  mode_of_transport  :string
#  uuid               :uuid
#  validity           :daterange
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  counterpart_hub_id :integer
#  group_id           :uuid
#  hub_id             :integer
#  legacy_user_id     :integer
#  organization_id    :uuid
#  sandbox_id         :uuid
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#  user_id            :uuid
#
# Indexes
#
#  index_local_charges_on_direction          (direction)
#  index_local_charges_on_group_id           (group_id)
#  index_local_charges_on_hub_id             (hub_id)
#  index_local_charges_on_load_type          (load_type)
#  index_local_charges_on_organization_id    (organization_id)
#  index_local_charges_on_sandbox_id         (sandbox_id)
#  index_local_charges_on_tenant_id          (tenant_id)
#  index_local_charges_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_local_charges_on_user_id            (user_id)
#  index_local_charges_on_uuid               (uuid) UNIQUE
#  index_local_charges_on_validity           (validity) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
