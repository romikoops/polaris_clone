# frozen_string_literal: true

module Pdf
  class Base
    attr_reader :organization, :user, :scope, :theme, :query

    def initialize(query:)
      @query = query
      @organization = query.organization
      @user = query.client
      @theme = @organization.theme
      @scope = ::OrganizationManager::ScopeService.new(
        target: user,
        organization: organization
      ).fetch
    end
  end
end
