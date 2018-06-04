class Hash
	def deep_values
		self.values.map { |value| value.is_a?(Hash) ? value.deep_values : value }.flatten
  end
  
  def map_deep_values(&block)
		self.map_values { |value| value.is_a?(Hash) ? value.map_deep_values(&block) : yield(value) }
	end

  def map_deep_values!(&block)
		self.map_values! { |value| value.is_a?(Hash) ? value.map_deep_values!(&block) : yield(value) }
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