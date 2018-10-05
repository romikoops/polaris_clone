class TableDropper
  def self.perform(options={})
    models_to_delete = determine_models_to_delete(options)
    undelete_models  = []

    models_to_delete.each_with_index do |model, i|
      begin
        if i > 1000
          undelete_models = models_to_delete[1001..-1].uniq
          log_not_deleted_models(undelete_models)
          break
        end
        model.delete_all
      rescue StandardError => e
        models_to_delete << model
      end
    end

    deleted_models = (models_to_delete - undelete_models).map(&:to_s)
    log_success_message(deleted_models) unless deleted_models.empty?
  end

  def self.all_table_names
    Rails.application.eager_load!
    ApplicationRecord.descendants.map(&:to_s)
  end

  private

  def self.log_not_deleted_models(models)
    puts "Not able to delete the following models: #{models.log_format}".red
  end

  def self.log_success_message(deleted_models)
    puts "Successfully deleted all data from the " \
         "following models: #{deleted_models.log_format}".green
  end

  def self.determine_models_to_delete(options)
    return options[:only] if valid_array_option_passed?(options[:only])

    Rails.application.eager_load!
    if valid_array_option_passed?(options[:except])
      return ApplicationRecord.descendants - options[:except]
    end

    ApplicationRecord.descendants
  end

  def self.valid_array_option_passed?(option)
    option.is_a?(Array) && !option.empty?
  end
end