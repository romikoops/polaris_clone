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
#  mode_of_transport  :string
#  load_type          :string
#  hub_id             :integer
#  tenant_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  tenant_vehicle_id  :integer
#  counterpart_hub_id :integer
#  direction          :string
#  fees               :jsonb
#  dangerous          :boolean          default(FALSE)
#  effective_date     :datetime
#  expiration_date    :datetime
#  user_id            :integer
#  uuid               :uuid
#  sandbox_id         :uuid
#  group_id           :uuid
#  internal           :boolean          default(FALSE)
#
