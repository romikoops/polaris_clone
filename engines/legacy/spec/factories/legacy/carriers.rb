FactoryBot.define do
  factory :legacy_carrier, class: 'Legacy::Carrier' do
    name { 'Hapag Lloyd' }
    sequence(:code) { |n| "hpg#{n}" }
  end
end

# == Schema Information
#
# Table name: carriers
#
#  id         :bigint           not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
# Indexes
#
#  index_carriers_on_sandbox_id  (sandbox_id)
#
