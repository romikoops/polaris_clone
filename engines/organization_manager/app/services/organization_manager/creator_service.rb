# frozen_string_literal: true

module OrganizationManager
  class CreatorService
    def initialize(params:)
      @organization_params = params.slice(:name, :slug)
      @scope_params = params[:scope]
      @theme_params = params[:theme]
    end

    def perform
      organization
    end

    private

    attr_reader :scope, :theme, :organization_params, :scope_params, :theme_params

    def organization
      @organization ||= Organizations::Organization.new(slug: organization_params[:slug]).tap do |organization|
        organization.scope = Organizations::Scope.new(target: organization, content: JSON.parse(scope_params || "{}"))
        organization.domains.new(default: true, domain: "#{organization.slug}.itsmycargo.shop")
        organization.theme = Organizations::Theme.new(theme_params.merge(organization_id: organization.id))
        organization.save
      end
    end
  end
end
