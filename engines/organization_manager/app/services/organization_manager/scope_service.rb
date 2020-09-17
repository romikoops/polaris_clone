# frozen_string_literal: true

module OrganizationManager
  class ScopeService
    def initialize(target: nil, organization: nil)
      @target = target
      @organization = organization
    end

    def fetch(*keys)
      if !keys.empty?
        scope.dig(*keys)
      else
        scope
      end
    end

    private

    attr_reader :target, :organization

    def scope
      @scope ||= begin
        resolved_scope = hierarchy.each_with_object(Organizations::DEFAULT_SCOPE.deep_dup) { |hierachy_target, result|
          next unless Organizations::Scope.exists?(target: hierachy_target)

          result.deep_merge!(Organizations::Scope.find_by(target: hierachy_target).content)
        }

        resolved_scope.with_indifferent_access
      end
    end

    def hierarchy
      @hierarchy ||= HierarchyService.new(target: target, organization: organization).fetch
    end
  end
end
