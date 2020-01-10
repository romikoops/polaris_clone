# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_agency, class: 'Legacy::Agency' do
    name { 'Agency Name' }

    association :tenant, factory: :legacy_tenant
    association :agency_manager, factory: :legacy_user
  end
end
