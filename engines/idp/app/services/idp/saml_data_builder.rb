# frozen_string_literal: true

module IDP
  class SamlDataBuilder
    attr_reader :saml_response, :organization_id, :data, :errors, :user

    delegate :company_attributes, :address_attributes, to: :saml_response

    def initialize(saml_response:, organization_id:)
      @saml_response = saml_response
      @organization_id = organization_id
      @invalid_record = nil
      @errors = []
      @data = nil
    end

    def perform
      @user = set_user
      attach_to_groups
      attach_to_company
      token = create_token

      @data = token.merge(userId: user.id, organizationId: organization_id)
      self
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      self
    end

    private

    def attach_to_groups
      group_names = saml_response.groups
      return if group_names.blank?

      groups = Groups::Group.where(name: group_names, organization: organization)
      return if groups.empty?

      Groups::Membership.where(member: user).where.not(group: groups)&.destroy_all
      groups.each do |group|
        Groups::Membership.find_or_create_by!(member: user, group: group)
      end
    end

    def attach_to_company
      return if company.nil?

      Companies::Membership.where(client: user).where.not(company: company).destroy_all
      Companies::Membership.find_or_initialize_by(client: user, company: company).tap do |membership|
        membership.branch_id = company_attributes[:external_id]
        membership.save!
      end
    end

    def set_user
      Users::Client.find_or_initialize_by(
        organization: organization,
        email: saml_response.email || saml_response.name_id
      ).tap do |saml_user|
        update_or_create_profile(saml_user: saml_user)
        update_or_create_settings(saml_user: saml_user)

        saml_user.save!
      end
    end

    def update_or_create_profile(saml_user:)
      if saml_user.profile.present?
        saml_user.profile.assign_attributes(saml_response.profile_attributes)
      else
        saml_user.profile = Users::ClientProfile.new(saml_response.profile_attributes)
      end
    end

    def update_or_create_settings(saml_user:)
      if saml_user.settings.present?
        saml_user.profile.assign_attributes(saml_response.profile_attributes)
      else
        saml_user.settings = Users::ClientSettings.new(currency: default_currency)
      end
    end

    def create_token
      token = Doorkeeper::AccessToken.create!(resource_owner_id: user.id,
                                              refresh_token: refresh_token,
                                              application: Doorkeeper::Application.find_by(name: "dipper"),
                                              expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
                                              scopes: "public")

      Doorkeeper::OAuth::TokenResponse.new(token).body
    end

    def refresh_token
      loop do
        token = SecureRandom.hex(32)
        break token unless Doorkeeper::AccessToken.exists?(refresh_token: token)
      end
    end

    def address
      Legacy::Address.create!(
        country: Legacy::Country.find_by(code: saml_response.country),
        **saml_response.address_attributes
      )
    end

    def default_currency
      OrganizationManager::ScopeService.new(
        target: nil, organization: organization
      ).fetch(:default_currency)
    end

    def organization
      @organization ||= Organizations::Organization.find(organization_id)
    end

    def company
      company_name = company_attributes[:name].presence || company_attributes[:external_id].presence
      return default_company unless company_name

      Companies::Company.find_or_create_by(name: company_name, organization: organization).tap do |comp|
        comp.address = address
        comp.save!
      end
    end

    def default_company
      @default_company ||= Companies::Company.find_by(
        name: "default",
        organization: organization
      )
    end
  end
end