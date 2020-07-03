# frozen_string_literal: true

module Organizations
  class Scope < ApplicationRecord
    belongs_to :target, polymorphic: true

    validates :target, presence: true
    validates_uniqueness_of :target_id, scope: :target_type
  end
end

# == Schema Information
#
# Table name: organizations_scopes
#
#  id          :uuid             not null, primary key
#  content     :jsonb
#  target_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  target_id   :uuid
#
# Indexes
#
#  index_organizations_scopes_on_target_type_and_target_id  (target_type,target_id) UNIQUE
#
