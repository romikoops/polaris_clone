# frozen_string_literal: true

module Rack
  class Attack
    ### Prevent Brute-Force Login Attacks ###

    # Throttle GET requests to /users/validate by IP address
    #
    throttle("*/users/validate", limit: 1, period: 20.seconds) do |req|
      req.ip if (%r{users/validate}).match?(req.path)
    end
  end
end
