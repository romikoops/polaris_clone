# frozen_string_literal: true

module Api
  class TenantSerializer < Api::ApplicationSerializer
    attributes :slug, :name
  end
end
