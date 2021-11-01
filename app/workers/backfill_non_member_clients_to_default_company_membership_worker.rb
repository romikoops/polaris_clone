# frozen_string_literal: true

class BackfillNonMemberClientsToDefaultCompanyMembershipWorker
  include Sidekiq::Worker

  FailedClientBackFill = Class.new(StandardError)
  def perform
    ActiveRecord::Base.transaction do
      memberships_to_be_deleted = memberships_without_company
      users_clients = memberships_to_be_deleted.map(&:client).compact
      memberships_to_be_deleted.destroy_all
      assign_default_company_to_clients(clients: users_clients)
      raise FailedQueryIdBackFill if memberships_without_company.present?
    end
  end

  private

  def assign_default_company_to_clients(clients:)
    clients.each do |client|
      default_company = Companies::Company.find_by(
        name: "default",
        organization: client.organization
      )
      next unless default_company

      Companies::Membership.create!(
        client: client,
        company: default_company
      )
    end
  end

  def memberships_without_company
    Companies::Membership.where.not(company_id: Companies::Company.pluck(:id))
  end
end
