# frozen_string_literal: true

module Api
  module V2
    class ClientDecorator < ApplicationDecorator
      decorates "Users::Client"
      decorates_association :profile, with: ProfileDecorator
      delegate_all
      delegate :first_name, :last_name, :phone, :company_name, to: :profile, allow_nil: true

      def email
        object.email.to_s
      end
    end
  end
end
