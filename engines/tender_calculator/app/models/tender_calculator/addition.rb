# frozen_string_literal: true

module TenderCalculator
  class Addition < Node
    TooManyChildrenError = Class.new(TreeError)

    def values
      left, right = children.map(&:values)
      left.zip(right).map { |pair| pair.reduce(:+) }
    end

    def <<(child)
      raise TooManyChildrenError if children.count >= 2

      super
    end
  end
end
