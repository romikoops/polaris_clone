# frozen_string_literal: true

require 'bigdecimal'

class Charge < Legacy::Charge
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint           not null, primary key
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  charge_breakdown_id         :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  edited_price_id             :integer
#  parent_id                   :integer
#  price_id                    :integer
#  sandbox_id                  :uuid
#
# Indexes
#
#  index_charges_on_charge_category_id           (charge_category_id)
#  index_charges_on_children_charge_category_id  (children_charge_category_id)
#  index_charges_on_sandbox_id                   (sandbox_id)
#
