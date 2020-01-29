module Trucking
  class Courier < ApplicationRecord
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    has_many :rates, class_name: 'Trucking::Rate'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
  end
end

# == Schema Information
#
# Table name: trucking_couriers
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#  tenant_id  :integer
#
# Indexes
#
#  index_trucking_couriers_on_sandbox_id  (sandbox_id)
#  index_trucking_couriers_on_tenant_id   (tenant_id)
#
