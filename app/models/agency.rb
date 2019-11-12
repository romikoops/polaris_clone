# frozen_string_literal: true

class Agency < ApplicationRecord
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
