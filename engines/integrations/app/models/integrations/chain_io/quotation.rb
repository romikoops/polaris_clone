# frozen_string_literal: true

module Integrations
  module ChainIo
    class Quotation < Quotations::Quotation
      has_many :tenders, inverse_of: :quotation
      has_one :cargo
    end
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  billing              :integer          default("external")
#  completed            :boolean          default(FALSE)
#  creator_type         :string
#  error_class          :string
#  estimated            :boolean
#  selected_date        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  creator_id           :uuid
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
#  index_quotations_quotations_on_creator_id_and_creator_type  (creator_id,creator_type)
#  index_quotations_quotations_on_destination_nexus_id         (destination_nexus_id)
#  index_quotations_quotations_on_legacy_user_id               (legacy_user_id)
#  index_quotations_quotations_on_organization_id              (organization_id)
#  index_quotations_quotations_on_origin_nexus_id              (origin_nexus_id)
#  index_quotations_quotations_on_sandbox_id                   (sandbox_id)
#  index_quotations_quotations_on_tenant_id                    (tenant_id)
#  index_quotations_quotations_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
