# frozen_string_literal: true

module Api
  module V2
    class ProfileDecorator < ApplicationDecorator
      decorates "Users::ClientProfile"
      decorates_association :user, with: ClientDecorator
      delegate_all
      delegate :email, :company_name, to: :user

      def company_name
        @company_name ||= Companies::Company.joins(:memberships).where(companies_memberships: { client_id: user_id }).pluck(:name).first.to_s
      end

      def new_user?
        @new_user ||= Doorkeeper::AccessToken.where(application: application, resource_owner_id: user_id).count < 2
      end

      def application
        @application ||= context[:application]
      end
    end
  end
end
