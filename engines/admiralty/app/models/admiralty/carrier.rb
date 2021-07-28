# frozen_string_literal: true

module Admiralty
  class Carrier < Routing::Carrier
    before_validation :downcase_code, on: :create
    after_validation :persist_legacy_carrier, on: :create

    def downcase_code
      code.downcase!
    end

    def persist_legacy_carrier
      Legacy::Carrier.create_with(name: name).find_or_initialize_by(code: code.downcase)
    end
  end
end
