# frozen_string_literal: true

module OrganizationManager
  class GroupsService < OrganizationManager::HierarchyService
    def initialize(target: nil, organization: nil, exclude_default: false)
      super(target: target, organization: organization)

      @exclude_default = exclude_default
    end

    def fetch
      @fetch ||= target_hierarchy.flatten.compact
    end

    private

    attr_reader :target, :organization, :exclude_default

    def target_hierarchy
      return [default_group] unless target

      target_groups = groups_for(members: [target])
      groups_groups = groups_for(members: [target_groups])

      [target_groups, groups_groups, company_hierachy, default_group]
    end

    def company_hierachy
      membership = ::Companies::Membership.find_by(client: target)
      return [] unless membership

      groups_for(members: [membership.company])
    end

    def default_group
      return if exclude_default

      @default_group ||= Groups::Group.find_by(name: "default", organization: organization)
    end
  end
end
