module Pdf
  class Base
    attr_reader :organization, :user, :scope, :theme

    def initialize(organization:, user:, sandbox: nil)
      @organization = organization
      @user = user
      @theme = @organization.theme
      @scope = ::OrganizationManager::ScopeService.new(
        target: @user,
        organization: @organization
      ).fetch
      @sandbox = sandbox
    end
  end
end
