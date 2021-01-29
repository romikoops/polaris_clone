# frozen_string_literal: true

module Api
  module V1
    class UserDecorator < ApplicationDecorator
      decorates "Users::User"

      delegate_all
      delegate :first_name, :last_name, :phone, :company_name, to: :profile

      def email
        object.email.to_s
      end

      def organization_id
        object.organization_id
      end

      def membership
        Users::Membership.find_by(user_id: id)
      end
    end
  end
end
