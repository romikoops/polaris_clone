# frozen_string_literal: true

FactoryBot.define do
  factory :cms_data_widget, class: "CmsData::Widget" do
    sequence(:name) { |n| "Widget-#{n}" }
    data { "Widget Data" }
    sequence(:order) { |n| n }
    association :organization, factory: :organizations_organization
  end
end
