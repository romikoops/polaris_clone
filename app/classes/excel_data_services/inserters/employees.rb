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
        user = Organizations::User.find_by(email: params[:email], organization: @organization)
        user ||= Authentication::User.create!(
          type: 'Organizations::User',
          password: params[:password],
          organization_id: @organization.id,
          email: params[:email]
        )
        user = user.becomes(Organizations::User)
        ::Companies::Membership.first_or_create(company: params[:company], member: user)
        update_or_create_employee_profile(employee: user, params: params)
        add_stats(user, params[:row_nr], true)
      end

      def update_or_create_employee_profile(employee:, params:)
        Profiles::ProfileService.create_or_update_profile(user: employee,
                                                          first_name: params[:first_name],
                                                          last_name: params[:last_name],
                                                          phone: params[:phone])
      end
    end
  end
end
