# frozen_string_literal: true

require "active_support/concern"

# Enables us to use AR model setters to manipulate scope values in the content hash
module ContentSetter
  extend ActiveSupport::Concern

  SEPARATOR = "$"

  def define_setters_and_getters
    Organizations::DEFAULT_SCOPE.each_key do |attribute|
      # Define the dynamic setters
      generate_extended_keys_and_define_caller_method(attribute) if Organizations::DEFAULT_SCOPE[attribute].is_a?(Hash)
      define_setter(attribute: attribute)
    end
  end

  def key_name(extended_key:)
    arrayified_keys = extended_key.split(SEPARATOR)
    arrayified_keys[1...].join(" ").humanize.titleize
  end

  private

  def define_setter(attribute:)
    define_method("#{attribute}=") do |input|
      input = ScopeValue.new(attributes: attribute.split(SEPARATOR), input: input).perform
      if attribute.include?(ContentSetter::SEPARATOR)
        hash_path = attribute.split(SEPARATOR)
        nested_hash_key_path = hash_path[0..-2]

        # The code below is to handle the scenario when the hash is not a part of content but is present in defaults and we have defined a getter for it.
        # In that case, we set the hash from the defaults to the content hash
        content.deep_merge!(attribute.split(SEPARATOR).reverse.inject(input) { |h, s| { s => h } }) if content.dig(*nested_hash_key_path).nil?
        content.dig(*nested_hash_key_path)[hash_path.last] = input
      else
        content[attribute] = input
      end
    end
  end

  # A generic "nested hash to string" implementation, intended primarily to be
  # used for jsonb column types with trestle to support nested hashes with any levels.
  #
  # ==== Attributes
  #
  # * +key+ - Is a hash key whose value is a nested hash.
  #
  # ==== Examples
  # For a Hash {"consolidate" => {"cargo" => {"backend" => true, "frontend" => true}}}
  # when called as generate_extended_key_and_define_method("consolidate")
  # This method does the following :
  # - Converts Hash keys into single keys such as {"consolidate$cargo$backend" => true, "consolidate$cargo$frontend" => true}
  # - Creates a setter method for consolidate$cargo$backend and consolidate$cargo$frontend.
  # - Creates a getter method for consolidate$cargo$backend and consolidate$cargo$frontend to return the value from the hash.
  # - Defines a getter method for root key to get a list of all its associated extended keys.
  #
  def generate_extended_keys_and_define_caller_method(key)
    extended_keys = []
    arrayified_result(Organizations::DEFAULT_SCOPE[key]).each do |sub_arr|
      extended_key = sub_arr[0...-1].reduce(key) do |extend_key, current_key|
        extend_key + ContentSetter::SEPARATOR + current_key
      end
      define_setter(attribute: extended_key)
      define_getter(attribute: extended_key)
      extended_keys << extended_key
    end
    send(:define_method, key.pluralize) { extended_keys }
  end

  def arrayified_result(hash_obj)
    result = []
    arrayify(hash_obj, result)
    result
  end

  def arrayify(obj, result, keys_array = [])
    if obj.is_a?(Hash)
      obj.each { |key, val| arrayify(val, result, keys_array + [key]) }
    else
      result << (keys_array + [obj])
    end
  end

  def define_getter(attribute:)
    define_method(attribute.to_s) do
      return content.dig(*attribute.split(SEPARATOR))
    end
  end

  # Class to ensure the correct value is stored in the hash
  class ScopeValue
    def initialize(attributes:, input:)
      @attributes = attributes
      @input = input
    end

    def perform
      if [true, false].include?(default_value)
        ActiveRecord::Type::Boolean.new.cast(input)
      elsif default_value.is_a?(Integer)
        input.to_i
      elsif default_value.is_a?(NilClass)
        input.presence || nil
      else
        input
      end
    end

    private

    attr_reader :attributes, :input

    def default_value
      Organizations::DEFAULT_SCOPE.dig(*attributes)
    end
  end
end
