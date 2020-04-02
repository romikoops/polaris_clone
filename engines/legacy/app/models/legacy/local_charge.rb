# frozen_string_literal: true

module Legacy
  class LocalCharge < ApplicationRecord
    self.table_name = 'local_charges'
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle', optional: true
    belongs_to :counterpart_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    scope :for_mode_of_transport, ->(mot) { where(mode_of_transport: mot.downcase) }
    scope :for_load_type, ->(load_type) { where(load_type: load_type.downcase) }
    scope :for_dates, (lambda do |start_date, end_date|
      where('validity && daterange(?::date, ?::date)', start_date, end_date)
    end)

    before_validation :set_validity

    def hub_name
      hub&.name
    end

    def counterpart_hub_name
      counterpart_hub&.name
    end

    def carrier_name
      tenant_vehicle&.carrier&.name
    end

    def service_level
      tenant_vehicle&.name
    end

    def set_validity
      self.validity = Range.new(effective_date.to_date, expiration_date.to_date)
    end
  end
end

# == Schema Information
#
# Table name: local_charges
#
#  id                 :bigint           not null, primary key
#  dangerous          :boolean          default(FALSE)
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
#  sandbox_id         :uuid
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#  user_id            :integer
#
# Indexes
#
#  index_local_charges_on_direction          (direction)
#  index_local_charges_on_group_id           (group_id)
#  index_local_charges_on_hub_id             (hub_id)
#  index_local_charges_on_load_type          (load_type)
#  index_local_charges_on_sandbox_id         (sandbox_id)
#  index_local_charges_on_tenant_id          (tenant_id)
#  index_local_charges_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_local_charges_on_uuid               (uuid) UNIQUE
#  index_local_charges_on_validity           (validity) USING gist
#
