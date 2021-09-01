# frozen_string_literal: true

module ResultFormatter
  class ClientDecorator < ApplicationDecorator
    decorates "Users::Client"
    delegate_all
    delegate :first_name, :last_name, :phone, to: :profile
    delegate :id, :name, to: :company, prefix: true
    delegate :payment_terms, to: :company

    def company
      @company ||= companies_membership ? companies_membership.company : default_company
    end

    def companies_membership
      Companies::Membership.find_by(client: object)
    end

    def default_company
      Companies::Company.find_by(name: "default", organization: organization)
    end

    def profile
      object.profile.presence || Users::ClientProfile.new
    end
  end
end
