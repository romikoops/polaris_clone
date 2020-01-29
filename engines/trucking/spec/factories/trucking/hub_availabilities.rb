FactoryBot.define do
  factory :trucking_hub_availability, class: 'Trucking::HubAvailability' do
    association :hub, factory: :legacy_hub
    association :type_availability, factory: :trucking_type_availability
  end
end

# == Schema Information
#
# Table name: trucking_hub_availabilities
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  hub_id               :integer
#  sandbox_id           :uuid
#  type_availability_id :uuid
#
# Indexes
#
#  index_trucking_hub_availabilities_on_sandbox_id  (sandbox_id)
#
