# frozen_string_literal: true

FactoryBot.define do
  factory :local_charge do
    association :hub
    association :tenant_vehicle
    direction { 'export' }
    load_type { 'lcl' }
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
#  sandbox_id         :uuid
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#  user_id            :integer
#
# Indexes
#
#  index_local_charges_on_sandbox_id  (sandbox_id)
#  index_local_charges_on_tenant_id   (tenant_id)
#  index_local_charges_on_uuid        (uuid) UNIQUE
#  index_local_charges_on_validity    (validity) USING gist
#
