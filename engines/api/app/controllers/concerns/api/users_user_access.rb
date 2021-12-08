# frozen_string_literal: true

module Api
  module UsersUserAccess
    extend ActiveSupport::Concern

    included do
      before_action :authorize_users_user
    end

    def authorize_users_user
      return true if current_user.is_a?(Users::User)

      head :unauthorized
    end
  end
end
