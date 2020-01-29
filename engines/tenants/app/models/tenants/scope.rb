# frozen_string_literal: true

module Tenants
  class Scope < ApplicationRecord
    belongs_to :target, polymorphic: true
    validates_uniqueness_of :target_id, scope: :target_type
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
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
