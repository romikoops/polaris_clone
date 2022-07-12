# frozen_string_literal: true

module Api
  module V2
    module Admin
      class GroupsMembershipDecorator < Draper::Decorator
        delegate_all

        def name
          @name ||= member_name
        end

        private

        def member_name
          case object.member_type
          when "Users::Client"
            object.member.present? ? object.member.first_name : ""
          when "Companies::Company", "Groups::Group"
            object.member.name
          else
            ""
          end
        end
      end
    end
  end
end
