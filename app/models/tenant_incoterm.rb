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
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  incoterm_id :integer
#  tenant_id   :integer
#
# Indexes
#
#  index_tenant_incoterms_on_tenant_id  (tenant_id)
#
