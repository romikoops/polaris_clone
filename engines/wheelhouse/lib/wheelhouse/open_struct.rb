# frozen_string_literal: true

module Wheelhouse
  class OpenStruct < ::OpenStruct
    alias read_attribute_for_serialization send
  end
end
