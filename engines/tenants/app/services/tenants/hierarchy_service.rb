# frozen_string_literal: true

module Tenants
  class HierarchyService
    def initialize(user:)
      @user = user
    end

    def perform
      [user.groups,
       user.tenant.groups,
       user.tenant,
       user.company.groups,
       user.company,
       user].flatten
    end

    private

    attr_reader :user
  end
end
