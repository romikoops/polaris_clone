# frozen_string_literal: true

module Tenants
  class HierarchyService
    def initialize(target: nil, organization: nil)
      @target = target
      @organization = organization || target&.organization
    end

    def fetch
      @fetch ||= [organization_hierarchy, target_hierarchy].flatten.compact
    end

    private

    attr_reader :target, :organization

    def organization_hierarchy
      return [] unless organization

      [Groups::Group.where(organization_id: organization.id), organization]
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
      return [] unless target.respond_to?(:company) && target.company.present?

      [
        target.company.groups.map(&:groups),
        target.company.groups,
        target.company
      ]
    end
  end
end
