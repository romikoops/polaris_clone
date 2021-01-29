# frozen_string_literal: true

module Organizations
  class Scope < ApplicationRecord
    extend ContentSetter

    belongs_to :target, polymorphic: true

    validates :target, presence: true
    validates_uniqueness_of :target_id, scope: :target_type

    define_setters(*Organizations::DEFAULT_SCOPE.keys)

    def method_missing(meth, *args, &blk)
      if content.has_key?(meth.to_s)
        content.fetch(meth.to_s)
      elsif Organizations::DEFAULT_SCOPE.has_key?(meth.to_s)
        Organizations::DEFAULT_SCOPE.fetch(meth.to_s)
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      content.has_key?(meth.to_s) || Organizations::DEFAULT_SCOPE.has_key?(meth.to_s) || super
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
