# frozen_string_literal: true

module Quotations
  class Quotation < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :user, optional: true, class_name: 'Legacy::User'
    belongs_to :tenants_user, optional: true, class_name: 'Tenants::User'
    belongs_to :origin_nexus, class_name: 'Legacy::Nexus'
    belongs_to :destination_nexus, class_name: 'Legacy::Nexus'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    has_many :tenders, inverse_of: :quotation
    has_one :cargo, class_name: 'Cargo::Cargo'
    belongs_to :pickup_address, class_name: 'Legacy::Address', optional: true
    belongs_to :delivery_address, class_name: 'Legacy::Address', optional: true
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  selected_date        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  delivery_address_id  :integer
#  destination_nexus_id :integer
#  origin_nexus_id      :integer
#  pickup_address_id    :integer
#  sandbox_id           :bigint
#  tenant_id            :uuid
#  tenants_user_id      :uuid
#  user_id              :bigint
#
# Indexes
#
#  index_quotations_quotations_on_destination_nexus_id  (destination_nexus_id)
#  index_quotations_quotations_on_origin_nexus_id       (origin_nexus_id)
#  index_quotations_quotations_on_sandbox_id            (sandbox_id)
#  index_quotations_quotations_on_tenant_id             (tenant_id)
#  index_quotations_quotations_on_user_id               (user_id)
#
