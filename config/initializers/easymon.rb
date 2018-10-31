# frozen_string_literal: true

Easymon::Repository.add('application-database', Easymon::ActiveRecordCheck.new(ActiveRecord::Base), :critical)
