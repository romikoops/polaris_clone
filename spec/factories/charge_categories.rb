# frozen_string_literal: true

FactoryBot.define do
  factory :charge_category do
    name { 'Grand Total' }
    code { 'grand_total' }
  end
end

# == Schema Information
#
# Table name: charge_categories
#
#  id            :bigint(8)        not null, primary key
#  name          :string
#  code          :string
#  cargo_unit_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tenant_id     :integer
#
