# frozen_string_literal: true

module Api
  module V1
    class UserDecorator < ApplicationDecorator
      decorates 'Users::User'

      delegate_all
      delegate :first_name, :last_name, :phone, :company_name, to: :profile

      def profile
        @profile ||= Profiles::Profile.find_by(user_id: id)
      end

      def membership
        Organizations::Membership.find_by(user_id: object.id)
      end
    end
  end
end
