# frozen_string_literal: true

module OrganizationManager
  class HierarchyService
    def initialize(target: nil, organization: nil)
      @target = target
      @organization = organization
    end

    def fetch
      @fetch ||= target_hierarchy.flatten.compact
    end

    private

    attr_reader :target, :organization

    def target_hierarchy
      return [organization] unless target

      target_groups = groups_for(members: [target])
      groups_groups = groups_for(members: [target_groups])

      [organization, default_group, company_hierachy, groups_groups, target_groups, target]
    end

    def groups_for(members:)
      Groups::Membership.where(member: members).map(&:group)
    end

    def company_hierachy
      membership = ::Companies::Membership.find_by(client: target)
      return [] unless membership

      [groups_for(members: [membership.company]), membership.company]
    end

    def default_group
      @default_group ||= Groups::Group.find_by(name: "default", organization: organization)
    end
  end
end
