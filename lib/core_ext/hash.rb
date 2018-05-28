class Hash
	def deep_values
		return self.values if self.values.none? { |value| value.is_a?(Hash) }
		self.values.map { |value| value.is_a?(Hash) ? value.deep_values : value }.flatten
	end

	def map_values
		self.each_with_object({}) do |(k, v), return_h|
			return_h[k] = yield(v)
		end
	end

	def map_values!
		self.each do |k, v|
			self[k] = yield(v)
		end
  end

  def each_deep_key(&block)
    each do |key, value|
      yield(key)
      value.each_deep_key(&block) if value.is_a? Hash
    end
  end

  def deep_each(&block)
    each do |key, value|
      yield(key, value)
      value.each_deep_key(&block) if value.is_a? Hash
    end
  end
end