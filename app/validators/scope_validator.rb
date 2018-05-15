class ScopeValidator < ActiveModel::EachValidator
  SCOPES = %w(
    cargo_info_level dangerous_goods detailed_billing fixed_currency has_customs has_insurance
    incoterm_info_level modes_of_transport terms carriage_options
  ) 
  LOAD_TYPES         = %w(cargo_item container)
  DIRECTIONS         = %w(import export)
  MODES_OF_TRANSPORT = %w(ocean rail air)
  CARRIAGE_OPTIONS   = %w(on_carriage pre_carriage)

  def validate_each(record, attribute, value)
    @record    = record
    @attribute = attribute
    @value     = value

    unless value.is_a?(Hash)
      add_error 'must be a Hash'
      return
    end
    
    value.deep_stringify_keys!
    
    unless value.deep_values.all? { |value| is_a_boolean?(value) || value.is_a?(String) }
      add_error 'last level values must be Boolean or String'
    end

    missing_scopes = SCOPES - value.keys
  	unless missing_scopes.empty?
      add_error "is missing the following keys: #{missing_scopes.log_format}"
    end

    MODES_OF_TRANSPORT.each do |mode_of_transport|
      unless has_mode_of_transport?(mode_of_transport)
        add_error "must have '#{mode_of_transport}' mode of transport"
      end
    end

  	CARRIAGE_OPTIONS.each do |carriage_option|
  		unless has_carriage_option?(carriage_option)
  			add_error "must be set for '#{carriage_option}' for both import and export"
  		end
  	end
  end

  private

  def add_error(message)
   	@record.errors[@attribute] << message
  end

  def has_mode_of_transport?(mode_of_transport)
    @value.dig("modes_of_transport", mode_of_transport) &&
    (@value.dig("modes_of_transport", mode_of_transport).keys - LOAD_TYPES).empty?
  end

  def has_carriage_option?(carriage_option)
  	@value.dig("carriage_options", carriage_option) &&
  	(@value.dig("carriage_options", carriage_option).keys - DIRECTIONS).empty?
  end

  def is_a_boolean?(arg)
    [TrueClass, FalseClass].include?(arg.class)
  end
end