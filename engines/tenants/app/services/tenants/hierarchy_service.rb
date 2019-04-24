# frozen_string_literal: true

module Tenants
  class HierarchyService
    def initialize(user: nil, tenant: nil)
      @user = user
      @tenant = tenant
    end

    def fetch
      return [tenant] if tenant.present? && user.nil?
      return [] if tenant.nil? && user.nil?

      [
        user.tenant&.groups,
        user.tenant,
        user.company&.groups,
        user.company,
        user.groups,
        user
      ].flatten.compact
    end

    private

    attr_reader :user, :tenant
  end
end
