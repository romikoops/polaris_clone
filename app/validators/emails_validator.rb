class EmailsValidator < ActiveModel::EachValidator
  BRANCHES = %w(sales support)

  def validate_each(record, attribute, value)
    @record    = record
    @attribute = attribute

    unless value.is_a?(Hash)
      add_error 'must be a Hash'
      return
    end
    
    value.deep_stringify_keys!
    
    missing_branches = BRANCHES - value.keys
  	unless missing_branches.empty?
      add_error "is missing the following keys: #{missing_branches.log_format}"
    end

    BRANCHES.each do |branch|
      unless value[branch].is_a?(Hash)
        add_error "'#{branch}' branch must be a Hash"
        next
      end

      unless value[branch]['general']
        add_error "'#{branch}' branch must have a general email"
      end

      value[branch].each do |mode_of_transport, email|
      	unless email.is_a?(String)
      		add_error "'#{branch} - #{mode_of_transport}' email must be a string"
      	end

      	unless email.match(/\A[^@\s]+@[^@\s]+\z/)
      		add_error "'#{branch} - #{mode_of_transport}' email is invalid"
      	end
      end
    end
  end

  private

  def add_error(message)
   	@record.errors[@attribute] << message
  end
end