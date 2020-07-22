# frozen_string_literal: true

module TenderCalculator
  class Node
    TreeError = Class.new(StandardError)

    attr_reader :children, :rate

    def initialize(rate: nil)
      @rate = rate
      @children = []
    end

    def <<(child)
      @children << child
    end
  end
end
