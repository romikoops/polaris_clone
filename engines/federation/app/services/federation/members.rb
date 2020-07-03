# frozen_string_literal: true

module Federation
  class Members
    def initialize(organization:)
      @organization = organization
    end

    def list
      ## TODO : IMPLEMENT FEDERATION LOGIC
      []
    end

    private

    attr_reader :organization
  end
end
