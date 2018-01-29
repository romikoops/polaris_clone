class ScopeValidator < ActiveModel::EachValidator
  SCOPES             = %w(dangerous_goods modes_of_transport) 
  LOAD_TYPES         = %w(cargo_item container)
  MODES_OF_TRANSPORT = %w(ocean rail air)

  def validate_each(record, attribute, value)
    @record    = record
    @attribute = attribute
    @value     = value

    add_error('must be a Hash') unless value.is_a?(Hash)

    value.deep_stringify_keys!
    
    unless value.deep_values.all? { |value| is_a_boolean?(value) }
      add_error('last level values must be Boolean')
    end

  	add_error("must have the following scopes: #{SCOPES.log_format}") unless value.keys.sort == SCOPES

  	MODES_OF_TRANSPORT.each do |mode_of_transport|
  		unless has_mode_of_transport?(mode_of_transport)
  			add_error("must have '#{mode_of_transport}' mode of transport scope")
  		end
  	end 
  end

  private

  def add_error(message)
   	@record.errors[@attribute] << message
  end

  def has_mode_of_transport?(mode_of_transport)
  	@value.dig("modes_of_transport", mode_of_transport) &&
  	@value.dig("modes_of_transport", mode_of_transport).keys.sort == LOAD_TYPES
  end

  def is_a_boolean?(arg)
    [TrueClass, FalseClass].include?(arg.class)
  end
end