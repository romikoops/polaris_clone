require "active_support/concern"

module ContentSetter
  extend ActiveSupport::Concern

  def define_setters(*attrs)
    attrs.each do |attr|
      # Define the dynamic setters
      define_method("#{attr.to_sym}=") do |val|
        content[attr] = val
      end
    end
  end
end
