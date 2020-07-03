# frozen_string_literal: true

Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base), :critical)
Easymon::Repository.add("redis", Easymon::RedisCheck.new(url: ENV.fetch("REDIS_URL")), :critical) if ENV["REDIS_URL"]
Easymon::Repository.add("memcached", Easymon::MemcachedCheck.new(Rails.cache), :critical) if ENV["MEMCACHED_HOST"]
