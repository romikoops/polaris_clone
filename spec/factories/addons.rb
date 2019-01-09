FactoryBot.define do
  factory :addon do
    
  end
end

# == Schema Information
#
# Table name: addons
#
#  id                   :bigint(8)        not null, primary key
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
