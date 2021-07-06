# frozen_string_literal: true

module Api
  module V2
    class ClientDecorator < ApplicationDecorator
      decorates "Users::Client"
      delegate_all
      delegate :first_name, :last_name, :phone, to: :profile

      def email
        object.email.to_s
      end

      def company_name
        profile.company_name.to_s
      end
    end
  end
end
