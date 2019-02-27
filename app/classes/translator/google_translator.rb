# frozen_string_literal: true

require 'google/cloud/translate'
module Translator
  class GoogleTranslator < Translator::BaseTranslator
    attr_reader :translate, :results, :origin_language, :target_language, :text, :tenant

    def post_initialize(_args)
      # Imports the Google Cloud client library
      # Your Google Cloud Platform project ID
      project_id = 'halogen-rampart-109720'

      # Instantiates a client
      @translate = Google::Cloud::Translate.new project: project_id
    end

    def perform
      perform_translation
    end

    protected

    def perform_translation
      translation = translate.translate @text, from: @origin_language, to: @target_language
    end
  end
end
