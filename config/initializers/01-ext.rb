# frozen_string_literal: true

ROVER_VERSION = "0.3.0"
raise "Invalid rover-df version, expected #{ROVER_VERSION}, got #{Rover::VERSION}" if Rover::VERSION != ROVER_VERSION

require_relative "../../lib/ext/rover/data_frame"
require_relative "../../lib/ext/rover/vector"
