# frozen_string_literal: true

module Quotations
  class Quotation < ApplicationRecord
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :user, optional: true, class_name: 'Organizations::User'
    belongs_to :origin_nexus, class_name: 'Legacy::Nexus'
    belongs_to :destination_nexus, class_name: 'Legacy::Nexus'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    has_many :tenders, inverse_of: :quotation
    has_one :cargo, class_name: 'Cargo::Cargo'
    belongs_to :pickup_address, class_name: 'Legacy::Address', optional: true
    belongs_to :delivery_address, class_name: 'Legacy::Address', optional: true

    enum billing: {external: 0, internal: 1, test: 2}
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  billing              :integer          default("external")
#  selected_date        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  delivery_address_id  :integer
#  destination_nexus_id :integer
#  legacy_shipment_id   :integer
#  legacy_user_id       :bigint
#  organization_id      :uuid
#  origin_nexus_id      :integer
#  pickup_address_id    :integer
#  sandbox_id           :bigint
#  shipment_id          :integer
#  tenant_id            :uuid
#  tenants_user_id      :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_quotations_quotations_on_destination_nexus_id  (destination_nexus_id)
#  index_quotations_quotations_on_legacy_user_id        (legacy_user_id)
#  index_quotations_quotations_on_organization_id       (organization_id)
#  index_quotations_quotations_on_origin_nexus_id       (origin_nexus_id)
#  index_quotations_quotations_on_sandbox_id            (sandbox_id)
#  index_quotations_quotations_on_tenant_id             (tenant_id)
#  index_quotations_quotations_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
