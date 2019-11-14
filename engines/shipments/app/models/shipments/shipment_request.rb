# frozen_string_literal: true

module Shipments
  class ShipmentRequest < ApplicationRecord
    include AASM

    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    belongs_to :tender, class_name: 'Quotations::Tender'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :user, class_name: 'Tenants::User'

    has_many   :documents, as: :attachable
    has_many   :notifyees, class_name: 'ShipmentRequestContacts::Notifyee'
    has_one    :consignee, class_name: 'ShipmentRequestContacts::Consignee'
    has_one    :consignor, class_name: 'ShipmentRequestContacts::Consignor'

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
#  status        :string
#  cargo_notes   :string
#  notes         :string
#  incoterm_text :string
#  eori          :string
#  ref_number    :string           not null
#  submitted_at  :datetime
#  eta           :datetime
#  etd           :datetime
#  sandbox_id    :uuid
#  user_id       :uuid             not null
#  tenant_id     :uuid             not null
#  tender_id     :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
