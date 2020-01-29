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
#  accept_text          :string
#  additional_info_text :string
#  addon_type           :string
#  cargo_class          :string
#  decline_text         :string
#  direction            :string
#  fees                 :jsonb
#  mode_of_transport    :string
#  read_more            :string
#  text                 :jsonb            is an Array
#  title                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  counterpart_hub_id   :integer
#  hub_id               :integer
#  tenant_id            :integer
#  tenant_vehicle_id    :integer
#
# Indexes
#
#  index_addons_on_tenant_id  (tenant_id)
#
