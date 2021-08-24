# frozen_string_literal: true

class RemoveUsersClientsWithMixedcaseEmailWorker
  include Sidekiq::Worker

  def perform
    Users::Client.global.only_deleted.where("email != LOWER(email)").find_each do |client|
      # rubocop:disable Rails/SkipsModelValidations
      existing_client = Users::Client.global.find_by(email: client.email.downcase, organization: client.organization)
      if existing_client.present?
        Journey::Query.where(client: client).update_all(client_id: existing_client.id)
        Companies::Membership.where(member: client).update_all(member_id: existing_client.id)
        Groups::Membership.where(member: client).update_all(member_id: existing_client.id)
      end
      # rubocop:enable Rails/SkipsModelValidations
      client.really_destroy!
    end
  end
end
