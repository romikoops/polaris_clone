# frozen_string_literal: true

raise 'Not required in Ruby 2.7 (part of Enumerable)! Method can be removed.' if Array.method_defined?(:tally_by)

module ArrayRefinements
  refine Array do
    def tally_by
      Hash[group_by { |obj| yield(obj) }.map { |k, v| [k, v.size] }]
    end
  end
end
