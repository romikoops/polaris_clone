# frozen_string_literal: true

module Rover
  class DataFrame
    def concat(other)
      raise ArgumentError, "Must be a data frame" unless other.is_a?(DataFrame)

      size = self.size
      vectors.each do |k, v|
        @vectors[k] = Vector.new(v.to_a + (other[k] ? other[k].to_a : [nil] * other.size), type: :object) # Forcing :object type on join
      end
      (other.vector_names - vector_names).each do |k|
        @vectors[k] = Vector.new([nil] * size + other[k].to_a, type: :object) # Forcing :object type on join
      end
      self
    end

    def join(other, how:, on: nil)
      self_on, other_on =
        if on.is_a?(Hash)
          [on.keys, on.values]
        else
          on ||= keys & other.keys
          on = [on] unless on.is_a?(Array)
          [on, on]
        end

      check_join_keys(self, self_on)
      check_join_keys(other, other_on)

      indexed = other.to_a.group_by { |r| r.values_at(*other_on) }
      indexed.default = []

      left = how == "left"

      types = {}
      vectors = {}
      keys = (self.keys + other.keys).uniq
      keys.each do |k|
        vectors[k] = []
        types[k] = join_type(self.types[k], other.types[k])
      end

      each_row do |r|
        matches = indexed[r.values_at(*self_on)]
        if matches.empty?
          if left
            keys.each do |k|
              vectors[k] << r[k]
            end
          end
        else
          matches.each do |r2|
            keys.each do |k|
              vectors[k] << (r2[k].nil? ? r[k] : r2[k]) # Change here from `r2[k] || r[k]` which behaved badly with false as the value versus nil
            end
          end
        end
      end

      DataFrame.new(vectors, types: types)
    end

    #### CUSTOM IMC CODE ####

    def filter(arguments)
      self[arguments.keys.map { |key| (self[key] == arguments[key]) }.reduce(&:&)]
    end

    def group_by(column)
      self[[column]].to_a.uniq.map {|args| filter(args) }
    end
  end
end