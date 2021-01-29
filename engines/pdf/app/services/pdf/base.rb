module Pdf
  class Base
    attr_reader :organization, :user, :scope, :theme, :query, :offer

    def initialize(offer:)
      @offer = offer
      @query = offer.query
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
