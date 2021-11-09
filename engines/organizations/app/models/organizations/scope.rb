# frozen_string_literal: true

module Organizations
  class Scope < ApplicationRecord
    extend ContentSetter

    belongs_to :target, polymorphic: true

    validates :target, presence: true
    validates_uniqueness_of :target_id, scope: :target_type

    define_setters_and_getters

    def method_missing(meth, *args, &blk)
      method_name = meth.to_s
      if content.key?(method_name)
        content.fetch(method_name)
      elsif Organizations::DEFAULT_SCOPE.key?(method_name)
        Organizations::DEFAULT_SCOPE.fetch(method_name)
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      content.key?(meth.to_s) || Organizations::DEFAULT_SCOPE.key?(meth.to_s) || super
    end
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
