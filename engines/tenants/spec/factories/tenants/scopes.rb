# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_scope, class: 'Tenants::Scope' do
    content { { 'quote_notes' => 'Quote Notes from the FactoryBot Factory' } }
  end
end
