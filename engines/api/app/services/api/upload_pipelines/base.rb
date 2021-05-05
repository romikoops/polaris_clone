# frozen_string_literal: true

module Api
  module UploadPipelines
    class Base
      def self.get(pipeline:)
        return self if pipeline == "default"

        "Api::UploadPipelines::#{pipeline.camelize}".constantize
      end

      def initialize(organization_id:, file_wrapper:)
        @organization_id = organization_id
        @file_wrapper = file_wrapper
      end

      def perform
        # TODO: build default pipeline

        true
      end

      def message
        "File created."
      end

      private

      attr_reader :organization_id, :file_wrapper
    end
  end
end
