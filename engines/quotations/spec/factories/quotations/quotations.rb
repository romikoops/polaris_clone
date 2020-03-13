# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_quotation, class: 'Quotations::Quotation' do
    selected_date { Date.today }

    association :origin_nexus, factory: :legacy_nexus
    association :destination_nexus, factory: :legacy_nexus
    association :user, factory: :legacy_user, with_profile: true
    association :tenant, factory: :tenants_tenant
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  selected_date        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  destination_nexus_id :integer
#  origin_nexus_id      :integer
#  sandbox_id           :bigint
#  tenant_id            :uuid
#  user_id              :bigint
#
# Indexes
#
#  index_quotations_quotations_on_destination_nexus_id  (destination_nexus_id)
#  index_quotations_quotations_on_origin_nexus_id       (origin_nexus_id)
#  index_quotations_quotations_on_sandbox_id            (sandbox_id)
#  index_quotations_quotations_on_tenant_id             (tenant_id)
#  index_quotations_quotations_on_user_id               (user_id)
#
