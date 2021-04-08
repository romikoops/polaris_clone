# frozen_string_literal: true

module Api
  module V1
    class SettingSerializer < Api::ApplicationSerializer
      attributes %i[language locale]
    end
  end
end
