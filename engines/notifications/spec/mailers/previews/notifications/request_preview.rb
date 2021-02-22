# frozen_string_literal: true
module Notifications
  # Preview all emails at http://localhost:3000/rails/mailers/notifications/user
  class RequestPreview < ActionMailer::Preview
    def request_created
      Organizations.current_id = organization.id
      RequestMailer.with(
        organization: organization,
        query: query,
        note: "This is a test note",
        mode_of_transport: "ocean"
      ).request_created
    end

    private

    def organization
      FactoryBot.build(:organizations_organization)
    end

    def query
      FactoryBot.build(:journey_query, organization: organization)
    end
  end
end
