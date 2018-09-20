# frozen_string_literal: true

require './lib/core_ext/active_record/migration'

Dir[File.join(Rails.root, 'lib', 'core_ext', '*.rb')].each { |l| require l }
