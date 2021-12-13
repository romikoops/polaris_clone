# frozen_string_literal: true

module Api
  module UsersUserAccess
    extend ActiveSupport::Concern

    included do
      before_action :authorize_users_user
    end

    def authorize_users_user
      return head :unauthorized unless current_user.is_a?(Users::User)
      return head :unauthorized unless Users::Membership.exists?(user: current_user, organization: current_organization)
    end
  end
end
