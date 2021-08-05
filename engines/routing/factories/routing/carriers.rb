# frozen_string_literal: true
FactoryBot.define do
  factory :routing_carrier, class: "Routing::Carrier" do
    sequence(:name) { |n| "Carrier - #{n}" }
    sequence(:code) { |n| "carrier_#{n}" }
    sequence(:abbreviated_name) { |n| "C#{n}" }
    transient do
      with_logo { true }
    end
    after(:build) do |carrier, evaluator|
      carrier.logo.attach(io: StringIO.new, filename: "test-image.jpg", content_type: "image/jpg") if evaluator.with_logo
    end
  end
end

# == Schema Information
#
# Table name: routing_carriers
#
#  id               :uuid             not null, primary key
#  abbreviated_name :string
#  code             :string
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  routing_carriers_index  (name,code,abbreviated_name) UNIQUE
#
