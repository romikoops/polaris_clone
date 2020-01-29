# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Document, type: :model do
    it { is_expected.to have_attribute(:attachable_type) }
    it { is_expected.to have_attribute(:attachable_id) }
    it { is_expected.to respond_to(:attachable) }

    it 'is shipment attachable' do
      shipment_doc = FactoryBot.build(:shipments_document, :shipment_doc)
      expect(shipment_doc.attachable).to be_a(Shipments::Shipment)
    end

    it 'is shipment_request attachable' do
      request_doc = FactoryBot.build(:shipments_document, :request_doc)
      expect(request_doc.attachable).to be_a(Shipments::ShipmentRequest)
    end
  end
end

# == Schema Information
#
# Table name: shipments_documents
#
#  id              :uuid             not null, primary key
#  attachable_type :string           not null
#  doc_type        :integer
#  file_name       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachable_id   :uuid             not null
#  sandbox_id      :uuid
#
# Indexes
#
#  index_shipments_documents_on_attachable_type_and_attachable_id  (attachable_type,attachable_id)
#  index_shipments_documents_on_sandbox_id                         (sandbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
