# frozen_string_literal: true

module IDP
  class SamlDataBuilder
    attr_reader :user, :saml_response, :organization_id

    def initialize(saml_response:, organization_id:)
      @saml_response = saml_response
      @organization_id = organization_id
    end

    def perform
      @user = find_or_create_user
      find_or_create_profile(user: user)
      attach_to_groups
      attach_to_company
      token = create_token

      token.merge(userId: user.id, organizationId: organization_id)
    end

    def find_or_create_user
      Authentication::User.find_or_create_by!(
        type: "Organizations::User",
        organization_id: organization_id,
        email: saml_response.email || saml_response.name_id
      )
    end

    def find_or_create_profile(user:)
      Profiles::ProfileService.create_or_update_profile(
        user: user,
        **saml_response.profile_attributes
      )
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
                                              expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
                                              scopes: "public")
      Doorkeeper::OAuth::TokenResponse.new(token).body
    end

    private

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
  end
end
