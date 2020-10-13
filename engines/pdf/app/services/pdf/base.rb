module Pdf
  class Base
    attr_reader :organization, :user, :scope, :theme

    def initialize(quotation:)
      @quotation = quotation
      @organization = quotation.organization
      @user = quotation.user
      @theme = @organization.theme
      @scope = ::OrganizationManager::ScopeService.new(
        target: user,
        organization: organization
      ).fetch
    end
  end
end
