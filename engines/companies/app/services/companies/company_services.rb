# frozen_string_literal: true

module Companies
  class CompanyServices
    attr_reader :company

    InvalidCompany = Class.new(StandardError)

    def initialize(company:)
      @company = company
    end

    def destroy
      raise InvalidCompany if company.blank?

      ActiveRecord::Base.transaction do
        user_clients = company_memberships.map(&:client)
        company_memberships.destroy_all
        assign_default_company_to_clients(clients: user_clients)
        Groups::Membership.where(member: company).destroy_all
        company.destroy
      end
    end

    private

    def company_memberships
      @company_memberships ||= Companies::Membership.where(company: company)
    end

    def assign_default_company_to_clients(clients:)
      default_company = Companies::Company.find_by(
        name: "default",
        organization: Organizations.current_id
      )
      return if default_company.blank?

      clients.each do |client|
        Companies::Membership.create!(client: client, company: default_company)
      end
    end
  end
end
