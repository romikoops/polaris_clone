# frozen_string_literal: true

module Integrations
  module ChainIo
    class ShipmentRequest < Shipments::ShipmentRequest
      belongs_to :tender
      has_many :documents

      def created_by
        {
          username: user.legacy.full_name,
          email: user.email,
          first_name: user.legacy.first_name,
          last_name: user.legacy.last_name
        }
      end

      def incoterm_text
        super || ''
      end
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
