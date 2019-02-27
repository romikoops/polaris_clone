# frozen_string_literal: true


FactoryBot.define do
  factory :quotation do
    transient do
      shipment_count { 1 }
    end

    target_email { 'john@example.test' }
    name { 'NAME' }

    after(:build) do |quotation, evaluator|
      quotation.shipments = build_list(:shipment, evaluator.shipment_count)
    end
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint(8)        not null, primary key
#  target_email         :string
#  user_id              :integer
#  name                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  original_shipment_id :integer
#
