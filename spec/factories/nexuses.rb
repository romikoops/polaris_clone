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
#  id         :bigint           not null, primary key
#  latitude   :float
#  locode     :string
#  longitude  :float
#  name       :string
#  photo      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :integer
#  sandbox_id :uuid
#  tenant_id  :integer
#
# Indexes
#
#  index_nexuses_on_sandbox_id  (sandbox_id)
#  index_nexuses_on_tenant_id   (tenant_id)
#
