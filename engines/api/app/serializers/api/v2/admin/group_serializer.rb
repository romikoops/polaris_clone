# frozen_string_literal: true

module Api
  module V2
    module Admin
      class GroupSerializer < Api::ApplicationSerializer
        attributes %i[id name organization_id]
      end
    end
  end
end
