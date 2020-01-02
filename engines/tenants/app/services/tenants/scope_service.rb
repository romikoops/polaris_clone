# frozen_string_literal: true

module Tenants
  class ScopeService
    def initialize(target: nil, tenant: nil, sandbox: nil)
      @target = target
      @tenant = tenant || target&.tenant
      @sandbox = sandbox
    end

    def fetch(*keys)
      if !keys.empty?
        scope.dig(*keys)
      else
        scope
      end
    end

    private

    attr_reader :sandbox, :target, :tenant

    def scope
      @scope ||= begin
        resolved_scope = hierarchy.each_with_object(Tenants::DEFAULT_SCOPE.deep_dup) do |hierachy_target, result|
          next unless Tenants::Scope.exists?(target: hierachy_target, sandbox: sandbox)

          result.deep_merge!(Tenants::Scope.find_by(target: hierachy_target).content)
        end

        resolved_scope.with_indifferent_access
      end
    end

    def hierarchy
      @hierarchy ||= HierarchyService.new(target: target, tenant: tenant).fetch
    end
  end
end
