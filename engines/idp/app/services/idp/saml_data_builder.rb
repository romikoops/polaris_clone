# frozen_string_literal: true

module IDP
  class SamlDataBuilder
    attr_reader :saml_response, :organization_id

    def initialize(saml_response:, organization_id:)
      @saml_response = saml_response
      @organization_id = organization_id
    end

    def perform
      attach_to_groups
      attach_to_company
      token = create_token

      token.merge(userId: user.id, organizationId: organization_id)
    end

    private

    def user
      @user ||= Users::Client.find_or_initialize_by(
        organization_id: organization_id,
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
        saml_user.profile_attributes = saml_response.profile_attributes
      end
    end

    def update_or_create_settings(saml_user:)
      return if saml_user.settings.present?

      saml_user.settings_attributes = {currency: default_currency}
    end

    def attach_to_groups
      group_names = saml_response.groups
      return if group_names.blank?

      groups = Groups::Group.where(name: group_names, organization_id: organization_id)
      return if groups.empty?

      Groups::Membership.where(member: user).where.not(group: groups)&.destroy_all
      groups.each { |group| Groups::Membership.find_or_create_by!(member: user, group: group) }
    end

    def attach_to_company
      company_attributes = saml_response.company_attributes

      id = company_attributes[:external_id]
      name = company_attributes[:name]
      return if id.blank?

      company = Companies::Company.find_or_initialize_by(external_id: id, organization_id: organization_id)
      company.name = name
      company.address = address
      company.save!

      Companies::Membership.find_or_create_by!(member: user, company: company)
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
      Organizations::Scope.find_by(
        target_id: organization_id, target_type: "Organizations::Organization"
      ).content.dig(:default_currency)
    end
  end
end
