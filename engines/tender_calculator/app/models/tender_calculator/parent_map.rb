# frozen_string_literal: true

module TenderCalculator
  class ParentMap < Node
    def values
      children.map(&:values).flatten
    end
  end
end
