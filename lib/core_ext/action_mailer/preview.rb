# frozen_string_literal: true

require "active_support/descendants_tracker"

module ActionMailer
  class Preview
    class << self
      private

      def load_previews
        Rails.root.glob("**/*_preview.rb").sort.each { |file| require_dependency file }
      end
    end
  end
end
