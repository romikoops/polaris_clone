# frozen_string_literal: true

FactoryBot.define do
  factory :agency do
  end
end

# == Schema Information
#
# Table name: agencies
#
#  id                :bigint(8)        not null, primary key
#  name              :string
#  tenant_id         :integer
#  agency_manager_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
