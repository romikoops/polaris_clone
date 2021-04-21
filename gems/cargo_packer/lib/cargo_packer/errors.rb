# frozen_string_literal: true

module CargoPacker
  class Errors
    Failure = Class.new(StandardError)
    ItemsExceedWeightLimit = Class.new(Failure)
    PackingFailed = Class.new(Failure)
  end
end
