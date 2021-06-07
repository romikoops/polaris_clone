# frozen_string_literal: true

module Legacy
  class Nexus < ApplicationRecord
    self.table_name = "nexuses"

    include PgSearch::Model
    belongs_to :organization, class_name: "Organizations::Organization"
    has_many :hubs, class_name: "Legacy::Hub", dependent: :destroy
    belongs_to :country, class_name: "Legacy::Country"

    pg_search_scope :name_search, against: %i[name], using: {
      tsearch: { prefix: true }
    }

    validates :locode, format: { with: /\A[A-Z]{2}[A-Z\d]{3}\z/, message: "Invalid Locode" }, allow_nil: true
  end
end

# == Schema Information
#
# Table name: nexuses
#
#  id              :bigint           not null, primary key
#  latitude        :float
#  locode          :string
#  longitude       :float
#  name            :string
#  photo           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  country_id      :integer
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_nexuses_on_organization_id  (organization_id)
#  index_nexuses_on_sandbox_id       (sandbox_id)
#  index_nexuses_on_tenant_id        (tenant_id)
#  nexus_upsert                      (locode,organization_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
