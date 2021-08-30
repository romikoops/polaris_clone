# frozen_string_literal: true

module Api
  module V2
    class UploadsSerializer < Api::ApplicationSerializer
      belongs_to :file
    end
  end
end
