# frozen_string_literal: true

module Api
  class ClientCreationService
    def initialize(client_attributes:, profile_attributes:, settings_attributes:, address_attributes: {}, group_id: nil)
      @client_attributes = client_attributes
      @profile_attributes = profile_attributes
      @settings_attributes = settings_attributes
      @address_attributes = address_attributes
      @group_id = group_id
    end

    def perform
      ActiveRecord::Base.transaction do
        client.save!
        attach_associations
        Rails.configuration.event_store.publish(
          Users::UserCreated.new(data: {user: client.to_global_id, organization_id: client.organization_id}),
          stream_name: "Organization$#{client.organization_id}"
        )
        client
      end
    end

    private

    attr_reader :client_attributes, :profile_attributes, :settings_attributes, :address_attributes, :group_id

    def client
      @client ||= Users::Client.new(client_attributes).tap do |new_user|
        new_user.profile = Users::ClientProfile.new(profile_attributes)
        new_user.settings = Users::ClientSettings.new(settings_attributes)
      end
    end

    def company
      Companies::Company.find_by(
        name: profile_attributes[:company_name] || "default",
        organization: client.organization
      )
    end

    def address
      @address ||= Legacy::Address.find_or_create_by!(address_from_params)
    end

    def attach_associations
      attach_company
      attach_group
      attach_address
    end

    def address_from_params
      {
        street_number: address_attributes[:house_number],
        street: address_attributes[:street],
        city: address_attributes[:city],
        zip_code: address_attributes[:postal_code],
        country: Legacy::Country.find_by(name: address_attributes[:country])
      }
    end

    def attach_group
      return if group_id.nil?

      Groups::Membership.create!(member: client, group_id: group_id)
    end

    def attach_address
      return if address_attributes.blank?

      Legacy::UserAddress.create!(user: client, address: address)
    end

    def attach_company
      return if company.blank?

      Companies::Membership.create!(member: client, company: company)
    end
  end
end
