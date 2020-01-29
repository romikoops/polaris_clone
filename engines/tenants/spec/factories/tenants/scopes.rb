# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_scope, class: 'Tenants::Scope' do
    content { { 'quote_notes' => 'Quote Notes from the FactoryBot Factory' } }
  end
end

# == Schema Information
#
# Table name: tenants_scopes
#
#  id          :uuid             not null, primary key
#  content     :jsonb
#  target_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sandbox_id  :uuid
#  target_id   :uuid
#
# Indexes
#
#  index_tenants_scopes_on_sandbox_id                 (sandbox_id)
#  index_tenants_scopes_on_target_type_and_target_id  (target_type,target_id)
#
