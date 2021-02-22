# frozen_string_literal: true
guard :rspec, cmd: "bundle exec rspec" do
  # Main App
  watch("spec/spec_helper.rb") { "spec" }
  watch("app/controllers/application_controller.rb") { "spec/controllers" }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }

  # Engines
  watch(%r{^engines/(.+)/app/(.+)\.rb$}) { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }
  watch(%r{^engines/(.+)/lib/(.+)\.rb$}) { |m| "spec/#{m[1]}/lib/#{m[2]}_spec.rb" }
end
