# frozen_string_literal: true

module Rover
  class DataFrame
    NIL_ARRAY = [nil].freeze

    def concat(other)
      raise ArgumentError, "Must be a data frame" unless other.is_a?(DataFrame)

      size = self.size
      vectors.each do |k, v|
        @vectors[k] = Vector.new(v.to_a + (other[k] ? other[k].to_a : NIL_ARRAY * other.size), type: :object) # Forcing :object type on join
      end
      (other.vector_names - vector_names).each do |k|
        @vectors[k] = Vector.new((NIL_ARRAY * size) + other[k].to_a, type: :object) # Forcing :object type on join
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
        types[k] = :object # Overwriting this to avoid autoasssigned types coming up for ints and bools
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

    def blank_frame
      Rover::DataFrame.new(keys.zip([[]] * keys.size).to_h)
    end

    def filter(arguments)
      self[arguments.keys.map { |key| (self[key] == arguments[key]) }.reduce(&:&)] || blank_frame
    end

    def filter_any(arguments)
      self[arguments.keys.map { |key| (self[key] == arguments[key]) }.reduce(&:|)] || blank_frame
    end

    def first_row
      first.to_a.first
    end

    def group_by(columns)
      self[columns].to_a.uniq.map { |args| filter(args) }
    end

    def reject(arguments)
      self[arguments.keys.map { |key| (self[key] != arguments[key]) }.reduce(&:&)] || blank_frame
    end

    def uniq
      Rover::DataFrame.new(to_a.uniq)
    end
  end
end
