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
        attach_company!
        attach_group!
        attach_address!
        Rails.configuration.event_store.publish(
          Users::UserCreated.new(data: { user: client.to_global_id, organization_id: Organizations.current_id }),
          stream_name: "Organization$#{Organizations.current_id}"
        )
        client
      end
    end

    private

    attr_reader :client_attributes, :profile_attributes, :settings_attributes, :address_attributes, :group_id

    def client
      @client ||= restorable_client.present? ? fully_restored_client : newly_created_client
    end

    def company
      Companies::Company.find_by(
        name: profile_attributes[:company_name],
        organization: Organizations.current_id
      ) ||
        Companies::Company.find_by(
          name: "default",
          organization: Organizations.current_id
        )
    end

    def address
      @address ||= Legacy::Address.find_or_create_by!(address_from_params)
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

    def attach_group!
      return if group_id.nil?

      Groups::Membership.create!(member: client, group_id: group_id)
    end

    def attach_address!
      return if address_attributes.blank?

      Legacy::UserAddress.create!(user: client, address: address)
    end

    def attach_company!
      return if company.blank?

      Companies::Membership.where(client: client).where.not(company: company).destroy_all
      Companies::Membership.find_or_create_by!(client: client, company: company)
    end

    def fully_restored_client
      @fully_restored_client ||= restorable_client.tap do |restored_users_client|
        restored_users_client.restore
        restored_users_client.update!(password: client_attributes[:password])
        restored_users_client.profile.update!(profile_attributes)
        restored_users_client.settings.update!(settings_attributes)
      end
    end

    def restorable_client
      @restorable_client ||= Users::Client.only_deleted.find_by(email: client_attributes[:email].downcase) if client_attributes[:email].present?
    end

    def newly_created_client
      @newly_created_client ||= Users::Client.create!(client_attributes.merge(settings_attributes: settings_attributes, profile_attributes: profile_attributes))
    end
  end
end
