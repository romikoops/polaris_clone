# frozen_string_literal: true

FactoryBot.define do
  factory :nexus do
    name { 'Gothenburg' }
    latitude { '57.694253' }
    longitude { '11.854048' }
    association :tenant
    association :country
  end
end

# == Schema Information
#
# Table name: nexuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  tenant_id  :integer
#  latitude   :float
#  longitude  :float
#  photo      :string
#  country_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
