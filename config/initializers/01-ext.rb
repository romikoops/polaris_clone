# frozen_string_literal: true

raise "Invalid rover-df version, expected 0.2.6, got #{Rover::VERSION}" if Rover::VERSION != "0.2.6"

require_relative "../../lib/ext/rover/data_frame"
require_relative "../../lib/ext/rover/vector"
