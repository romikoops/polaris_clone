# frozen_string_literal: true

module Tenants
  class HierarchyService
    def initialize(user:)
      @user = user
    end

    def fetch
      return [] if user.nil?

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

    attr_reader :user
  end
end
