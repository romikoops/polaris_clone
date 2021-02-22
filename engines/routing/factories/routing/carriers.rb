# frozen_string_literal: true
FactoryBot.define do
  factory :routing_carrier, class: "Routing::Carrier" do
    sequence(:name) { |n| "Carrier - #{n}" }
    sequence(:abbreviated_name) { |n| "C#{n}" }
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
