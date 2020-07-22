# frozen_string_literal: true

module Shipments
  class Shipment < ApplicationRecord
    has_paper_trail

    belongs_to :destination, class_name: 'Routing::Terminal'
    belongs_to :origin, class_name: 'Routing::Terminal'
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :user, class_name: 'Organizations::User'

    has_many :documents, as: :attachable
    has_many :notifyees, class_name: 'Contact'

    has_one :consignee, class_name: 'Contact', required: true
    has_one :consignor, class_name: 'Contact', required: true
    has_one :cargo, required: true
    has_one :invoice, required: true
  end
end

# == Schema Information
#
# Table name: shipments_shipments
#
#  id                  :uuid             not null, primary key
#  eori                :string
#  incoterm_text       :string
#  notes               :string
#  status              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  destination_id      :uuid             not null
#  legacy_user_id      :uuid
#  organization_id     :uuid
#  origin_id           :uuid             not null
#  sandbox_id          :uuid
#  shipment_request_id :uuid
#  tenant_id           :uuid
#  user_id             :uuid
#
# Indexes
#
#  index_shipments_shipments_on_destination_id       (destination_id)
#  index_shipments_shipments_on_legacy_user_id       (legacy_user_id)
#  index_shipments_shipments_on_organization_id      (organization_id)
#  index_shipments_shipments_on_origin_id            (origin_id)
#  index_shipments_shipments_on_sandbox_id           (sandbox_id)
#  index_shipments_shipments_on_shipment_request_id  (shipment_request_id)
#  index_shipments_shipments_on_tenant_id            (tenant_id)
#  index_shipments_shipments_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (destination_id => routing_terminals.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (origin_id => routing_terminals.id)
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#  fk_rails_...  (user_id => users_users.id)
#
