# frozen_string_literal: true

module Api
  module V2
    class ProfileSerializer < Api::ApplicationSerializer
      attributes %i[email first_name last_name phone currency language locale]
      attribute :new_user, &:new_user?
    end
  end
end
