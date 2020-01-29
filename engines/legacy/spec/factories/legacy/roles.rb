# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_role, class: 'Legacy::Role' do
    name { 'shipper' }
  end
end

# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
