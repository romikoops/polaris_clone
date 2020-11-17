# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_local_charge, class: 'Legacy::LocalCharge' do
    association :hub, factory: :legacy_hub
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
    direction { 'export' }
    load_type { 'lcl' }
    mode_of_transport { 'ocean' }
    effective_date { Time.zone.today }
    expiration_date { Time.zone.today + 6.months }
    fees do
      {
        'SOLAS' => {
          'key' => 'SOLAS',
          'max' => nil,
          'min' => 17.5,
          'name' => 'SOLAS',
          'value' => 17.5,
          'currency' => 'EUR',
          'rate_basis' => 'PER_SHIPMENT'
        }
      }
    end
    group_id { default_group.id }

    transient do
      default_group do
        Groups::Group.find_by(organization: organization, name: 'default') ||
          FactoryBot.create(:groups_group, organization: organization, name: 'default')
      end
    end

    trait :range do
      fees do
        {
          'QDF' =>
            { 'key' => 'QDF',
              'max' => nil,
              'min' => 57,
              'name' => 'Wharfage / Quay Dues',
              'range' => [
                { 'max' => 5, 'min' => 0, 'ton' => 41, 'currency' => 'EUR' },
                { 'cbm' => 8, 'max' => 40, 'min' => 6, 'currency' => 'EUR' }
              ],
              'currency' => 'EUR',
              'rate_basis' => 'PER_UNIT_TON_CBM_RANGE' }
        }
      end
    end

    trait :multiple_fees do
      fees do
        {
          'SOLAS' => {
            'key' => 'SOLAS',
            'max' => nil,
            'min' => 17.5,
            'name' => 'SOLAS',
            'value' => 17.5,
            'currency' => 'EUR',
            'rate_basis' => 'PER_SHIPMENT'
          },
          'QDF' =>
            { 'key' => 'QDF',
              'max' => nil,
              'min' => 57,
              'name' => 'Wharfage / Quay Dues',
              'range' => [
                { 'max' => 5, 'min' => 0, 'ton' => 41, 'currency' => 'EUR' },
                { 'cbm' => 8, 'max' => 40, 'min' => 6, 'currency' => 'EUR' }
              ],
              'currency' => 'EUR',
              'rate_basis' => 'PER_UNIT_TON_CBM_RANGE' }
        }
      end
    end

    after(:create) do |local_charge|
      local_charge.fees.each do |key, fee|
        next if Legacy::ChargeCategory.exists?(organization: local_charge.organization, code: key.downcase)

        FactoryBot.create(:legacy_charge_categories, organization: local_charge.organization, code: key.downcase, name: fee['name'])
      end
    end
  end
end

# == Schema Information
#
# Table name: local_charges
#
#  id                 :bigint           not null, primary key
#  dangerous          :boolean          default(FALSE)
#  direction          :string
#  effective_date     :datetime
#  expiration_date    :datetime
#  fees               :jsonb
#  internal           :boolean          default(FALSE)
#  load_type          :string
#  metadata           :jsonb
#  mode_of_transport  :string
#  uuid               :uuid
#  validity           :daterange
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  counterpart_hub_id :integer
#  group_id           :uuid
#  hub_id             :integer
#  old_user_id        :integer
#  organization_id    :uuid
#  sandbox_id         :uuid
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#  user_id            :uuid
#
# Indexes
#
#  index_local_charges_on_direction          (direction)
#  index_local_charges_on_group_id           (group_id)
#  index_local_charges_on_hub_id             (hub_id)
#  index_local_charges_on_load_type          (load_type)
#  index_local_charges_on_organization_id    (organization_id)
#  index_local_charges_on_sandbox_id         (sandbox_id)
#  index_local_charges_on_tenant_id          (tenant_id)
#  index_local_charges_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_local_charges_on_user_id            (user_id)
#  index_local_charges_on_uuid               (uuid) UNIQUE
#  index_local_charges_on_validity           (validity) USING gist
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
