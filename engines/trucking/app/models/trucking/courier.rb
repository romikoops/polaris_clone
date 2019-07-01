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
#  tenant_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
