# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Employees < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          update_or_create_employee(params)
        end

        stats
      end

      private

      def update_or_create_employee(params)
        user = Users::Client.find_by(email: params[:email], organization: @organization)
        user ||= Users::Client.new(
          password: params[:password],
          organization_id: @organization.id,
          email: params[:email],
          profile_attributes: {
            first_name: params[:first_name],
            last_name: params[:last_name],
            phone: params[:phone]
          },
          settings_attributes: {}
        )
        add_stats(user, params[:row_nr], true)
        return unless user.save

        ::Companies::Membership.first_or_create(company: params[:company], member: user)
      end
    end
  end
end
