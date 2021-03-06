# frozen_string_literal: true

module Legacy
  class Carrier < ApplicationRecord
    self.table_name = "carriers"

    acts_as_paranoid

    has_many :tenant_vehicles
    validates :code, uniqueness: { case_sensitive: false }, presence: true

    def get_tenant_vehicle(tenant_id, mode_of_transport, name)
      tv = tenant_vehicles.find_by(
        tenant_id: tenant_id,
        mode_of_transport: mode_of_transport,
        name: name
      )
      tv ||= Vehicle.create_from_name(name: name, mot: mode_of_transport, tenant_id: tenant_id, carrier: self.name)

      tv
    end
  end
end

# == Schema Information
#
# Table name: carriers
#
#  id         :bigint           not null, primary key
#  code       :string
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
# Indexes
#
#  index_carriers_on_code        (code) UNIQUE WHERE (deleted_at IS NULL)
#  index_carriers_on_sandbox_id  (sandbox_id)
#
