# frozen_string_literal: true

module Federation
  class Members
    def initialize(tenant: )
      @tenant = tenant
    end

    def list
      ## TODO : IMPLEMENT FEDERATION LOGIC
      []
    end

    private

    attr_reader :tenant
  end
end
