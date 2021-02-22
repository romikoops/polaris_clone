# frozen_string_literal: true
FactoryBot.define do
  factory :trucking_scope, class: "Trucking::Scope" do
    load_type { "cargo_item" }
    cargo_class { "lcl" }
    truck_type { "default" }
    carriage { "pre" }
    association :courier, factory: :trucking_courier
  end
end

# == Schema Information
#
# Table name: trucking_scopes
#
#  id          :uuid             not null, primary key
#  cargo_class :string
#  carriage    :string
#  load_type   :string
#  truck_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  courier_id  :uuid
#
