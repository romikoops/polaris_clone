# frozen_string_literal: true

FactoryBot.define do
  factory :quotation do
    association :user
    transient do
      shipment_count { 1 }
    end

    target_email { 'john@example.test' }
    name { 'NAME' }

    after(:build) do |quotation, evaluator|
      quotation.shipments = create_list(:shipment, evaluator.shipment_count, 
        user: quotation.user, 
        tenant: quotation.user.tenant,
        with_breakdown: true
      )
    end
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  target_email         :string
#  user_id              :integer
#  name                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  original_shipment_id :integer
#  sandbox_id           :uuid
#
