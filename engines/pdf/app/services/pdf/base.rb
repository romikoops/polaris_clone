module Pdf
  class Base
    attr_reader :tenant, :user, :tenants_tenant, :scope, :theme

    def initialize(tenant:, user:, sandbox: nil)
      @tenant = tenant
      @user = user
      @tenants_tenant = Tenants::Tenant.find_by(legacy_id: @tenant.id)
      @theme = @tenants_tenant.theme
      @scope = ::Tenants::ScopeService.new(
        target: ::Tenants::User.find_by(legacy_id: @user.id),
        tenant: @tenants_tenant
      ).fetch
      @sandbox = sandbox
    end
  end
end
