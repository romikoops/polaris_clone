# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_agency, class: 'Legacy::Agency' do
    name { 'Agency Name' }
  end
end
