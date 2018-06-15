require "#{Rails.root}/db/seed_classes/seeding_interface.rb"

def test_me
  puts "This is a test"
end

SeedingInterface.new(
  actions: {
    run_my_test_action: -> { test_me },
  },
  welcome_message: "Welcome to the Test Seeding Interface"
).init

