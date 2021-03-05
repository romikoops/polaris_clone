# frozen_string_literal: true

module Api
  class Scope
    attr_reader :content

    def initialize(content:)
      @content = content
    end

    def id
      SecureRandom.uuid
    end

    def method_missing(meth, *args, &blk)
      if content.has_key?(meth.to_s)
        content.fetch(meth.to_s)
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      content.has_key?(meth.to_s) || super
    end
  end
end
