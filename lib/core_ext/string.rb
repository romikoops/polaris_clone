class String
	def remove_extra_spaces!
		self.gsub!(/\s+/, " ").gsub!(/\s+,/, ",").strip!
			.gsub!(/^,/, "").gsub!(/,\z/, "").strip!
	end

	def remove_extra_spaces
		self.gsub(/\s+/, " ").gsub(/\s+,/, ",").strip
			.gsub(/^,/, "").gsub(/,\z/, "").strip
	end
end