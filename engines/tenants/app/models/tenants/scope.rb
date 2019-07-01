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
#  target_type :string
#  target_id   :uuid
#  content     :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sandbox_id  :uuid
#
