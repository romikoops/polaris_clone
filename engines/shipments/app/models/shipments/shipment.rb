# frozen_string_literal: true

module Shipments
  class Shipment < ApplicationRecord
    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    belongs_to :destination, class_name: 'Routing::Terminal'
    belongs_to :origin, class_name: 'Routing::Terminal'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :user, class_name: 'Tenants::User'

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
#  shipment_request_id :uuid
#  sandbox_id          :uuid
#  user_id             :uuid             not null
#  origin_id           :uuid             not null
#  destination_id      :uuid             not null
#  tenant_id           :uuid             not null
#  status              :string
#  notes               :string
#  incoterm_text       :string
#  eori                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
