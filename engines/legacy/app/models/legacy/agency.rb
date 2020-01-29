# frozen_string_literal: true

module Legacy
  class Agency < ApplicationRecord
    self.table_name = 'agencies'

    has_paper_trail

    has_many :users
    belongs_to :agency_manager, class_name: 'User', optional: true
    belongs_to :tenant
  end
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
