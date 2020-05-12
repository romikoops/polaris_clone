# frozen_string_literal: true

module TenderCalculator
  class Node
    TreeError = Class.new(StandardError)

    attr_reader :children

    def initialize
      @children = []
    end

    def <<(child)
      @children << child
    end
  end
end
