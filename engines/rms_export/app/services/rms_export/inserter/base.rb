# frozen_string_literal: true

module RmsExport
  module Inserter
    class Base
      def initialize(tenant_id:, data:)
        @tenant = Tenants::Tenant.find_by(id: tenant_id)
        @data = data
      end
    end
  end
end
