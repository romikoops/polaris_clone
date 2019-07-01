# frozen_string_literal: true

module Legacy
  class Nexus < ApplicationRecord
    self.table_name = 'nexuses'
    has_many :hubs, class_name: 'Legacy::Hub'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :country, class_name: 'Legacy::Country'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  end
end

# == Schema Information
#
# Table name: nexuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  tenant_id  :integer
#  latitude   :float
#  longitude  :float
#  photo      :string
#  country_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
