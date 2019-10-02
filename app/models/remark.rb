# frozen_string_literal: true

class Remark < ApplicationRecord
  belongs_to :tenant
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
end

# == Schema Information
#
# Table name: remarks
#
#  id          :bigint           not null, primary key
#  tenant_id   :bigint
#  category    :string
#  subcategory :string
#  body        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order       :integer
#  sandbox_id  :uuid
#
