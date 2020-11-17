# require "database_cleaner"
#
# RSpec.configure do |config|
#   config.around(:each, disable_transactional_examples: true) do |example|
#     original_use_transactional_examples = config.use_transactional_examples
#     config.use_transactional_examples = false
#
#     DatabaseCleaner[:active_record].strategy = :deletion
#     begin
#       DatabaseCleaner.cleaning do
#         example.run
#       end
#     ensure
#       config.use_transactional_examples = original_use_transactional_examples
#     end
#   end
# end
