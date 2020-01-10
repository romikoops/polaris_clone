# frozen_string_literal: true

FactoryBot.define do
  factory :rate_basis do
    external_code { 'PER_HBL' }
    internal_code { 'PER_SHIPMENT' }
  end
end

# == Schema Information
#
# Table name: rate_bases
#
#  id            :bigint           not null, primary key
#  external_code :string
#  internal_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
