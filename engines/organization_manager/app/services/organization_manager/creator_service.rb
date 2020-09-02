# frozen_string_literal: true

module OrganizationManager
  class CreatorService
    def initialize(params:)
      @organization_params = params.slice(:name, :slug)
      @scope_params = params[:scope]
      @theme_params = params[:theme]
    end

    def perform
      create_organization
    end

    private

    def create_organization
      @organization = Organizations::Organization.new(slug: organization_params[:slug]).tap do |organization|
        organization.scope = Organizations::Scope.new(target: organization, content: JSON.parse(scope_params))
        organization.domains.new(default: true, domain: "#{organization.slug}.itsmycargo.shop")
        organization.theme = Organizations::Theme.new(theme_params.merge(organization_id: organization.id))
        organization.save
      end
    end

    attr_reader :scope, :theme, :organization, :organization_params, :scope_params, :theme_params
  end
end
