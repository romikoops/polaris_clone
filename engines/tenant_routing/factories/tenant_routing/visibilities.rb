# frozen_string_literal: true

FactoryBot.define do
  factory :tenant_routing_visibility, class: "TenantRouting::Visibility" do
    association :target, factory: :organizations_organization
    association :connection, factory: :tenant_routing_connection
  end
end

# == Schema Information
#
# Table name: tenant_routing_visibilities
#
#  id            :uuid             not null, primary key
#  target_type   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  connection_id :uuid
#  target_id     :uuid
#
# Indexes
#
#  visibility_connection_index  (connection_id)
#  visibility_target_index      (target_type,target_id)
#
