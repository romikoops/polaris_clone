# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_agency, class: 'Legacy::Agency' do
    name { 'Agency Name' }

    association :tenant, factory: :legacy_tenant
    association :agency_manager, factory: :legacy_user
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
