# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_document, class: 'Shipments::Document' do
    trait :request_doc do
      attachable { |a| a.association(:shipments_shipment_request) }
    end

    trait :shipment_doc do
      attachable { |a| a.association(:shipments_shipment) }
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
