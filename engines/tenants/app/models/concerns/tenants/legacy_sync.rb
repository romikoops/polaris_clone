# frozen_string_literal: true

module Tenants
  module LegacySync
    extend ActiveSupport::Concern

    included do
      after_commit   :__legacy__create, on: :create
      after_commit   :__legacy__update, on: :update
      before_destroy :__legacy__destroy
    end

    def __legacy__create
      __legacy__target.create_from_legacy(self)
    end

    def __legacy__update
      __legacy__target.find_by(legacy_id: id)&.update_from_legacy(self)
    end

    def __legacy__destroy
      __legacy__target.find_by(legacy_id: id)&.destroy
    end

    private

    def __legacy__target
      case self
      when ::User
        ::Tenants::User
      when ::Tenant
        ::Tenants::Tenant
      end
    end
  end
end
