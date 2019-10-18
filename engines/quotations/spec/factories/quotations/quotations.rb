# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_quotation, class: 'Quotation' do
    selected_date { Date.today }

    association :origin_nexus, factory: :legacy_nexus 
    association :destination_nexus, factory: :legacy_nexus
    association :user, factory: :legacy_user
  end
end
