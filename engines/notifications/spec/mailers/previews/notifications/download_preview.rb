# frozen_string_literal: true

module Notifications
  class DownloadPreview < ActionMailer::Preview
    def complete_email
      Organizations.current_id = organization.id
      DownloadMailer.with(
        user: user,
        organization: organization,
        result: result,
        file_name: "hubs_sheet",
        category_identifier: "hubs",
        bcc: []
      ).complete_email
    end

    private

    def organization
      FactoryBot.build(:organizations_organization)
    end

    def user
      FactoryBot.build(:users_user, email: "test@itsmycargo.shop")
    end

    def document
      ExcelDataServices::FileWriters::Base.get("hubs").write_document(
        organization: organization,
        file_name: "hubs_sheet",
        user: user,
        options: {}
      )
    end

    def result
      {}.tap do |result|
        result[:has_errors] = false
        result[:errors] = []
        result[:document] = document
        result[:can_attach] = document.file.byte_size < 10.megabyte
      end
    end
  end
  end
