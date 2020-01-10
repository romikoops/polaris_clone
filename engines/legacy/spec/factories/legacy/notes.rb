
# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_note, class: 'Legacy::Note' do
    body { 'body' }
    header { 'header' }
    level { 'level' }
    target { build(:legacy_hub) }

    association :tenant, factory: :legacy_tenant
    association :itinerary, factory: :default_itinerary
    association :hub, factory: :legacy_hub
  end
end
