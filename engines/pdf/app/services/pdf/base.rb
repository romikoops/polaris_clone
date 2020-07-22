module Pdf
  class Base
    attr_reader :organization, :user, :scope, :theme

    def initialize(organization:, user:)
      @organization = organization
      @user = user
      @theme = @organization.theme
      @scope = ::OrganizationManager::ScopeService.new(
        target: @user,
        organization: @organization
      ).fetch
    end
  end
end
