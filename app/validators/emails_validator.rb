# frozen_string_literal: true

class EmailsValidator < ActiveModel::EachValidator
  BRANCHES = %w[sales support].freeze

  def validate_each(record, attribute, value)
    @record = record
    @attribute = attribute

    unless value.is_a?(Hash)
      add_error "must be a Hash"
      return
    end

    value.deep_stringify_keys!

    missing_branches = BRANCHES - value.keys
    add_error "is missing the following keys: #{missing_branches.log_format}" unless missing_branches.empty?

    BRANCHES.each do |branch|
      unless value[branch].is_a?(Hash)
        add_error "'#{branch}' branch must be a Hash"
        next
      end

      add_error "'#{branch}' branch must have a general email" unless value[branch]["general"]

      value[branch].each do |mode_of_transport, email|
        add_error "'#{branch} - #{mode_of_transport}' email must be a string" unless email.is_a?(String)

        add_error "'#{branch} - #{mode_of_transport}' email is invalid" unless /\A[^@\s]+@[^@\s]+\z/.match?(email)
      end
    end
  end

  private

  def add_error(message)
    @record.errors[@attribute] << message
  end
end
