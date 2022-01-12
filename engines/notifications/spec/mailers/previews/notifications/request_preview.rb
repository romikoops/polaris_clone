# frozen_string_literal: true
module Notifications
  # Preview all emails at http://localhost:3000/rails/mailers/notifications/user
  class RequestPreview < ActionMailer::Preview
    def request_created
      Organizations.current_id = organization.id
      RequestMailer.with(
        organization: organization,
        query: query,
        request_for_quotation: request_for_quotation,
      ).request_created
    end

    private

    def organization
      FactoryBot.build(:organizations_organization)
    end

    def query
      FactoryBot.build(:journey_query, organization: organization)
    end

    def request_for_quotation
      FactoryBot.build(:request_for_quotation, organization: organization, query: query)
    end
  end
end
