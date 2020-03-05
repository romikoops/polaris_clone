# frozen_string_literal: true

module Legacy
  class Nexus < ApplicationRecord
    self.table_name = 'nexuses'
    include PgSearch::Model
    has_many :hubs, class_name: 'Legacy::Hub'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :country, class_name: 'Legacy::Country'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    pg_search_scope :name_search, against: %i[name], using: {
      tsearch: { prefix: true }
    }
  end
end

# == Schema Information
#
# Table name: nexuses
#
#  id         :bigint           not null, primary key
#  latitude   :float
#  locode     :string
#  longitude  :float
#  name       :string
#  photo      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :integer
#  sandbox_id :uuid
#  tenant_id  :integer
#
# Indexes
#
#  index_nexuses_on_sandbox_id  (sandbox_id)
#  index_nexuses_on_tenant_id   (tenant_id)
#
