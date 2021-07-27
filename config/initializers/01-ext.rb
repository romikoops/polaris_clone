# frozen_string_literal: true

raise "Invalid rover-df version, expected 0.2.4, got #{Rover::VERSION}" if Rover::VERSION != "0.2.4"

require_relative "../../lib/ext/rover/vector"
