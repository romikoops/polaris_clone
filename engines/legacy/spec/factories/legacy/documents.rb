# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_document, class: 'Legacy::Document' do
    association :shipment
    association :tenant

    trait :with_file do
      after(:build) do |document|
        document.file.attach(io: StringIO.new, filename: 'test-image.jpg', content_type: 'image/jpg')
      end
    end

    factory :document_with_file, traits: [:with_file]
  end
end

# == Schema Information
#
# Table name: documents
#
#  id               :bigint           not null, primary key
#  approval_details :jsonb
#  approved         :string
#  doc_type         :string
#  text             :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  quotation_id     :integer
#  sandbox_id       :uuid
#  shipment_id      :integer
#  tenant_id        :integer
#  user_id          :integer
#
# Indexes
#
#  index_documents_on_sandbox_id  (sandbox_id)
#  index_documents_on_tenant_id   (tenant_id)
#
