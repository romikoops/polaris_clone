# frozen_string_literal: true
module ResultFormatter
  class ApplicationDecorator < Draper::Decorator
    def scope
      context.fetch(:scope, {})
    end
  end
end
