# frozen_string_literal: true

FactoryBot.define do
  factory :documents, class: 'Document' do
    association :shipment
    association :tenant

    trait :with_file do
      after(:build) do |document|
        document.file.attach(io: StringIO.new, filename: 'test-image.jpg', content_type: 'image/jpg')
      end
    end
  end
end

# == Schema Information
#
# Table name: documents
#
#  id               :bigint           not null, primary key
#  user_id          :integer
#  shipment_id      :integer
#  doc_type         :string
#  url              :string
#  text             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  approved         :string
#  approval_details :jsonb
#  tenant_id        :integer
#  quotation_id     :integer
#  sandbox_id       :uuid
#
