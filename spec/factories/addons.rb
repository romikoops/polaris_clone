# frozen_string_literal: true

FactoryBot.define do
  factory :addon do
    association :tenant
    text do
      [
        {
          'text' => 'Addon text 1'
        }
      ]
    end
    read_more { 'Read more..' }
    cargo_class { 'lcl' }
    direction { 'export' }
    addon_type { 'customs_export_paper' }
    fees do
      {
        'ADB' => {
          'key' => 'ADB',
          'name' => 'Customs Export Paper',
          'value' => 75.0,
          'currency' => 'EUR',
          'rate_basis' => 'PER_SHIPMENT'
        }
      }
    end
  end
end

# == Schema Information
#
# Table name: addons
#
#  id                   :bigint           not null, primary key
#  title                :string
#  text                 :jsonb            is an Array
#  tenant_id            :integer
#  read_more            :string
#  accept_text          :string
#  decline_text         :string
#  additional_info_text :string
#  cargo_class          :string
#  hub_id               :integer
#  counterpart_hub_id   :integer
#  mode_of_transport    :string
#  tenant_vehicle_id    :integer
#  direction            :string
#  addon_type           :string
#  fees                 :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
