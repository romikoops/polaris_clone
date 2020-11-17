# frozen_string_literal: true

FactoryBot.define do
  factory :application, class: 'Doorkeeper::Application' do
    sequence(:name) { |n| "application_name_#{n}" }
    redirect_uri { 'https://itsmycargo.com' }
  end
end
