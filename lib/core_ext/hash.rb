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
end