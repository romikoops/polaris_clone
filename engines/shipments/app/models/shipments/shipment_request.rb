# frozen_string_literal: true

module Shipments
  class ShipmentRequest < ApplicationRecord
    include AASM

    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    belongs_to :tender, class_name: 'Quotations::Tender'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :user, class_name: 'Tenants::User'
    belongs_to :tender, class_name: 'Quotations::Tender'
    has_many   :documents, as: :attachable
    has_many   :notifyees, class_name: 'ShipmentRequestContacts::Notifyee'
    has_one    :consignee, class_name: 'ShipmentRequestContacts::Consignee'
    has_one    :consignor, class_name: 'ShipmentRequestContacts::Consignor'

    delegate :itinerary, :mode_of_transport, :carrier, to: :tender

    aasm column: :status do
      state :created, initial: true
    end
  end
end

# == Schema Information
#
# Table name: shipments_shipment_requests
#
#  id            :uuid             not null, primary key
#  cargo_notes   :string
#  eori          :string
#  eta           :datetime
#  etd           :datetime
#  incoterm_text :string
#  notes         :string
#  ref_number    :string           not null
#  status        :string
#  submitted_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sandbox_id    :uuid
#  tenant_id     :uuid             not null
#  tender_id     :uuid             not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_shipments_shipment_requests_on_sandbox_id  (sandbox_id)
#  index_shipments_shipment_requests_on_tenant_id   (tenant_id)
#  index_shipments_shipment_requests_on_tender_id   (tender_id)
#  index_shipments_shipment_requests_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#  fk_rails_...  (tenant_id => tenants_tenants.id)
#  fk_rails_...  (tender_id => quotations_tenders.id)
#  fk_rails_...  (user_id => tenants_users.id)
#
