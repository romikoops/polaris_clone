# frozen_string_literal: true

class Agency < Legacy::Agency
end

# == Schema Information
#
# Table name: agencies
#
#  id                :bigint           not null, primary key
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  agency_manager_id :integer
#  tenant_id         :integer
#
# Indexes
#
#  index_agencies_on_tenant_id  (tenant_id)
#
