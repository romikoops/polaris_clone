# frozen_string_literal: true

module Legacy
  class Addon < ApplicationRecord
    self.table_name = 'addons'
    belongs_to :hub, class_name: 'Legacy::Hub'
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
