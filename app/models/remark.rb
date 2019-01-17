# frozen_string_literal: true

class Remark < ApplicationRecord
  belongs_to :tenant
end

# == Schema Information
#
# Table name: remarks
#
#  id          :bigint(8)        not null, primary key
#  tenant_id   :bigint(8)
#  category    :string
#  subcategory :string
#  body        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order       :integer
#
