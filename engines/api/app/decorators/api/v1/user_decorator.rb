# frozen_string_literal: true

module Api
  module V1
    class UserDecorator < ApplicationDecorator
      decorates "Users::User"
      delegate_all
      delegate :first_name, :last_name, :phone, to: :profile

      def email
        object.email.to_s
      end

      def company_name
        profile.company_name.to_s
      end

      def membership
        Users::Membership.find_by(user_id: id)
      end
    end
  end
end
