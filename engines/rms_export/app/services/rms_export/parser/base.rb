module RmsExport
  module Parser
    class Base
      def initialize(tenant_id:, sandbox: nil)
        @tenant = Tenants::Tenant.find_by(id: tenant_id)
        @sandbox = sandbox
      end
    end
  end
end