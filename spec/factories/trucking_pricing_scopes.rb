# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_pricing_scope do
    load_type { 'cargo_item' }
    cargo_class { 'lcl' }
    truck_type { 'default' }
    carriage { 'pre' }
    association :courier
  end
end

# == Schema Information
#
# Table name: trucking_pricing_scopes
#
#  id          :bigint(8)        not null, primary key
#  load_type   :string
#  cargo_class :string
#  carriage    :string
#  courier_id  :integer
#  truck_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
