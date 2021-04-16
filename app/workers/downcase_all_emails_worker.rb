# frozen_string_literal: true

class DowncaseAllEmailsWorker
  include Sidekiq::Worker

  def perform
    Users::Client.global.where("email != LOWER(email)").find_each do |client|
      existing_client = Users::Client.unscope.find_by(email: client.email.downcase, organization: client.organization)
      if existing_client.present?
        # rubocop:disable Rails/SkipsModelValidations
        Journey::Query.where(client: client).update_all(client_id: existing_client)
        Companies::Membership.where(member: client).update_all(member_id: existing_client)
        Groups::Membership.where(member: client).update_all(member_id: existing_client)
        # rubocop:enable Rails/SkipsModelValidations
        client.really_destroy!
      else
        client.update!(email: client.email.downcase)
      end
    end
  end
end
