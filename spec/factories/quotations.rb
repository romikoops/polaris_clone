# frozen_string_literal: true

FactoryBot.define do
  factory :quotation do
    association :user
    transient do
      shipment_count { 1 }
      load_type { 'cargo_item' }
    end

    target_email { 'john@example.test' }
    name { 'NAME' }

    after(:build) do |quotation, evaluator|
      original_shipment = create(:shipment,
        user: quotation.user,
        tenant: quotation.user.tenant,
        load_type: evaluator.load_type,
        with_breakdown: true)
      quotation.shipments = create_list(:shipment, evaluator.shipment_count,
        user: quotation.user,
        tenant: quotation.user.tenant,
        load_type: evaluator.load_type,
        with_breakdown: true
      )
      quotation.original_shipment_id = original_shipment.id
    end
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  target_email         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  original_shipment_id :integer
#  sandbox_id           :uuid
#  user_id              :integer
#
# Indexes
#
#  index_quotations_on_sandbox_id  (sandbox_id)
#
