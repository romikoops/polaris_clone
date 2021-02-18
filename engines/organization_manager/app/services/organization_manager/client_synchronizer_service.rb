# frozen_string_literal: true

module OrganizationManager
  class ClientSynchronizerService
    attr_reader :organization, :target_organizations, :emails

    def initialize(organization:, target_organizations:, emails:)
      @organization = organization
      @target_organizations = target_organizations
      @emails = emails
    end

    def perform
      target_organizations.each do |target_organization|
        non_existing_users_in_target(target: target_organization).find_each do |client|
          next unless client.valid?

          clone_client(client: client, target_organization: target_organization)
        end
      end
    end

    def clone_client(client:, target_organization:)
      ActiveRecord::Base.transaction do
        client.dup.tap do |new_client|
          new_client.organization = target_organization
          new_client.profile = client.profile.dup.tap { |new_profile| new_profile.user = new_client }
          new_client.settings = client.settings.dup.tap { |new_settings| new_settings.user = new_client }
          new_client.save!
        end
      end
    end

    def existing_users
      @existing_users ||= Users::Client.global.where(organization: organization, email: emails)
    end

    def non_existing_users_in_target(target:)
      existing_users.where.not(email: Users::Client.global.where(organization: target).select(:email))
    end
  end
end
