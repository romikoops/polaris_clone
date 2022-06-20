# frozen_string_literal: true

module Legacy
  module Upsertable
    def upsertable_id
      klass = self.class
      ::UUIDTools::UUID.sha1_create(
        ::UUIDTools::UUID.parse(klass::UUID_V5_NAMESPACE),
        klass::UUID_KEYS.map { |key| send(key).to_s }.join
      )
    end
  end
end
