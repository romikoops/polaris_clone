# frozen_string_literal: true

require_dependency "admiralty_tenants/application_controller"

module AdmiraltyTenants
  class OrganizationsController < ApplicationController
    before_action :set_organization, except: %i[index new create]

    def index
      @organizations = ::AdmiraltyTenants::OrganizationDecorator.decorate_collection(
        ::Organizations::Organization.order(:slug)
      )
    end

    def show
    end

    def new
      @organization = ::AdmiraltyTenants::OrganizationDecorator.new(Organizations::Organization.new)
      @render_scope = Organizations::DEFAULT_SCOPE
      @theme = Organizations::Theme.new
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(organization: @organization).order(:id)
    end

    def create
      organization = OrganizationManager::CreatorService.new(params: organization_params).perform
      if organization.persisted?
        Pricings::MarginCreator.create_default_margins(organization)
        OrganizationManager::AuxilliarySetupService.new(organization: organization).perform
        create_default_admin(organization: organization)
        create_default_shippers(organization: organization)
        redirect_to(organization_path(organization)) && return
      end
      @organization = ::AdmiraltyTenants::OrganizationDecorator.new(organization)
      @render_scope = Organizations::DEFAULT_SCOPE
      @theme = @organization.theme || Organizations::Theme.new
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(organization_id: @organization.id).order(:id)
      render :new
    end

    def edit
    end

    def update
      @organization.update(
        slug: organization_params[:slug],
        live: organization_params[:live]
      )
      @theme = @organization.theme
      @theme.update(organization_params[:theme]) if organization_params[:theme].present?
      @scope.update(content: remove_default_values)
      update_max_dimensions
      if @max_dimensions.all?(&:valid?)
        redirect_to organization_path(@organization)
      else
        render :edit
      end
    end

    private

    def set_organization
      @organization = ::AdmiraltyTenants::OrganizationDecorator.new(Organizations::Organization.find(params[:id]))
      @scope = @organization.scope || {}
      @render_scope = ::OrganizationManager::ScopeService.new(organization: @organization.object).fetch
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(organization_id: @organization.id).order(:id)
      @theme = @organization.theme || Organizations::Theme.new
    end

    def update_max_dimensions
      @max_dimensions.each do |md|
        md_params_id = max_dimensions_params[:max_dimensions][md.id.to_s]
        update_hash = md_params_id.to_h.compact
        md.update(update_hash)
      end
    end

    def organization_params
      params.require(:organization)
        .permit(
          :live,
          :slug,
          :scope,
          :max_dimensions_bundle,
          theme: %i[
            primary_color secondary_color bright_primary_color bright_secondary_color
            background small_logo large_logo email_logo white_logo wide_logo booking_process_image
            name
          ]
        )
    end

    def remove_default_values
      edited_scope = JSON.parse(organization_params[:scope])
      edited_scope.keys.each_with_object({}) do |key, hash|
        hash[key] = edited_scope[key] if edited_scope[key] != ::Organizations::DEFAULT_SCOPE[key]
      end
    end

    def max_dimensions_params
      params.permit(max_dimensions: {})
    end

    def create_default_admin(organization:)
      Organizations::Membership.create(user: Users::User.find_by(email: "shopadmin@itsmycargo.com"),
                                       organization: organization,
                                       role: :admin)
    end

    def create_default_shippers(organization:)
      %w[shipper@itsmycargo.com agent@itsmycargo.com].each do |email|
        ActiveRecord::Base.transaction do
          shipper = Authentication::User.create!(email: email,
                                                 organization_id: organization.id,
                                                 password: Settings.passwords&.default,
                                                 type: "Organizations::User").tap do |user|
            user.assign_attributes(activation_state: :active)
            user.save
          end
          Profiles::Profile.create!(user: shipper, company_name: "ItsMyCargo")
        end
      end
    end
  end
end
