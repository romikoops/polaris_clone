FactoryBot.define do
  factory :local_charge do
    association :hub
  end
end

# == Schema Information
#
# Table name: local_charges
#
#  id                 :bigint(8)        not null, primary key
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
#
