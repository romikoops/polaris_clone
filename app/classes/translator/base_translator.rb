# frozen_string_literal: true

module Translator
  class BaseTranslator
    attr_reader :results, :origin_language, :target_language, :text, :tenant

    def initialize(args = { _user: current_user })
      params = args[:params]
      @text = args[:text]
      @target_language = args[:target_language]
      @origin_language = args[:origin_language]
      @results = _results

      post_initialize(args)
    end

    def perform
      raise NotImplementedError, "This method must be implemented in #{self.class.name} "
    end

    protected

    def post_initialize(_args)
      nil
    end

    def _stats
      {
        type: 'trucking'
      }.merge(local_stats)
    end

    def local_stats
      {}
    end

    def _results
      {}
    end

    def open_json(path)
      JSON.parse(File.read("#{Rails.root}#{path}"))
    end

    def uuid
      SecureRandom.uuid
    end

    def debug_message(message)
      puts message if DEBUG
    end
  end
end
