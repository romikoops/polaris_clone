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

    def auth_methods
      ["password", saml_enabled ? "saml" : nil].compact
    end

    def saml_enabled
      Organizations::SamlMetadatum.exists?(organization_id: Organizations.current_id)
    end

    def method_missing(meth, *args, &blk)
      if content.key?(meth.to_s)
        content.fetch(meth.to_s)
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      content.key?(meth.to_s) || super
    end
  end
end
