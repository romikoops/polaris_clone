module Tenants
  class HierarchyService
    def initialize(tenant:, user:)
      @tenant = tenant
      @user = user
    end

    def perform
      
    end

    private

    attr_reader :tenant, :user
  end
end
