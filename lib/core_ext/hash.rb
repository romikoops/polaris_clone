class Hash
	def deep_values
		return self.values if self.values.none? { |value| value.is_a?(Hash) }
		self.values.map { |value| value.is_a?(Hash) ? value.deep_values : value }.flatten
	end
end