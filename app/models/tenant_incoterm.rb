# frozen_string_literal: true

class TenantIncoterm < ApplicationRecord
  belongs_to :tenant
  belongs_to :incoterm
end

# == Schema Information
#
# Table name: tenant_incoterms
#
#  id          :bigint           not null, primary key
#  tenant_id   :integer
#  incoterm_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
