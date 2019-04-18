module Tenants
  class ScopeService
    def initialize(tenant:, user:)
      @hierarchy = HierarchyService.new(tenant: tenant, user: user).perform
    end

    def perform
      hierarchy.each_with_object({}) do |member, result_scope|
        result_scope.merge!(member.scope)
      end
    end

    private

    attr_reader :hierarchy
  end
end
