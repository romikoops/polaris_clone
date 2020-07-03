# frozen_string_literal: true

FactoryBot.define do
  factory :map_datum do
  end
end

# == Schema Information
#
# Table name: map_data
#
#  id              :bigint           not null, primary key
#  destination     :decimal(, )      default([]), is an Array
#  geo_json        :jsonb
#  line            :jsonb
#  origin          :decimal(, )      default([]), is an Array
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  itinerary_id    :string
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_map_data_on_organization_id  (organization_id)
#  index_map_data_on_sandbox_id       (sandbox_id)
#  index_map_data_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
