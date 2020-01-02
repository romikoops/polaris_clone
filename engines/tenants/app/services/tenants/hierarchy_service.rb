# frozen_string_literal: true

module Tenants
  class HierarchyService
    def initialize(target: nil, tenant: nil)
      @target = target
      @tenant = tenant || target&.tenant
    end

    def fetch
      @fetch ||= [tenant_hierarchy, target_hierarchy].flatten.compact
    end

    private

    attr_reader :target, :tenant

    def tenant_hierarchy
      return [] unless tenant

      [tenant.groups, tenant]
    end

    def target_hierarchy
      return [] unless target

      [
        company_hierarchy,
        target.groups.map(&:groups),
        target.groups,
        target
      ]
    end

    def company_hierarchy
      return [] unless target&.company

      [
        target.company.groups.map(&:groups),
        target.company.groups,
        target.company
      ]
    end
  end
end
