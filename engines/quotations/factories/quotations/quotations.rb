# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_quotation, class: "Quotations::Quotation" do
    selected_date { Time.zone.today }

    origin_nexus { association(:legacy_nexus) }
    destination_nexus { association(:legacy_nexus) }
    user { association(:users_client) }
    creator { user }
    organization { association(:organizations_organization) }

    billing { :external }

    trait :container do
      after(:create) do |quotation|
        cargo = FactoryBot.create(:cargo_cargo, quotation_id: quotation.id)
        FactoryBot.create(:fcl_20_unit, cargo: cargo)
      end
    end

    trait :cargo_item do
      after(:create) do |quotation|
        cargo = FactoryBot.create(:cargo_cargo, quotation_id: quotation.id)
        FactoryBot.create(:lcl_unit, cargo: cargo)
      end
    end
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  completed            :boolean          default(FALSE)
#  selected_date        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  delivery_address_id  :integer
#  destination_nexus_id :integer
#  old_user_id          :bigint
#  organization_id      :uuid
#  legacy_shipment_id   :integer
#  origin_nexus_id      :integer
#  pickup_address_id    :integer
#  sandbox_id           :bigint
#  shipment_id          :integer
#  tenant_id            :uuid
#  tenants_user_id      :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_quotations_quotations_on_destination_nexus_id  (destination_nexus_id)
#  index_quotations_quotations_on_old_user_id           (old_user_id)
#  index_quotations_quotations_on_organization_id       (organization_id)
#  index_quotations_quotations_on_origin_nexus_id       (origin_nexus_id)
#  index_quotations_quotations_on_sandbox_id            (sandbox_id)
#  index_quotations_quotations_on_tenant_id             (tenant_id)
#  index_quotations_quotations_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
