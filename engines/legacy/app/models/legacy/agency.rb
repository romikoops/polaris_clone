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
#  tenant_id         :integer
#  agency_manager_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
