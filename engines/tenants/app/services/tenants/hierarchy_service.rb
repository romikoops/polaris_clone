# frozen_string_literal: true

module Tenants
  class HierarchyService
    def initialize(target: nil, tenant: nil)
      @target = target
      @tenant = tenant
    end

    def fetch
      return [] if tenant.nil? && target.nil?
      return [tenant] if tenant.present? && target.nil?

      case target.class.to_s
      when 'Tenants::Group'
        [
          target.tenant&.groups,
          target.tenant,
          target.groups&.map(&:groups)&.flatten,
          target.groups,
          target
        ].flatten.compact
      when 'Tenants::Company'
        [
          target.tenant&.groups,
          target.tenant,
          target.groups&.map(&:groups)&.flatten,
          target.groups,
          target
        ].flatten.compact
      else 'Tenants::User'
        [
          target.tenant&.groups,
          target.tenant,
          target.company&.groups&.map(&:groups)&.flatten,
          target.company&.groups,
          target.company,
          target.groups&.map(&:groups)&.flatten,
          target.groups,
          target
        ].flatten.compact
      end
    end

    private

    attr_reader :target, :tenant
  end
end
