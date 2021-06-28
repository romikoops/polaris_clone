# frozen_string_literal: true

raise "Invalid rover-df version, expected 0.2.3, got #{Rover::VERSION}" if Rover::VERSION != "0.2.3"

require_relative "../../lib/ext/rover/vector"
