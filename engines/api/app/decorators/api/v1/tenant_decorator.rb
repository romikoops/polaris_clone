# frozen_string_literal: true

module Api
  module V1
    class TenantDecorator < Draper::Decorator
      decorates 'Tenants::Tenant'

      delegate_all
      delegate :name, to: :legacy
    end
  end
end
