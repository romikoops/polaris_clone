class String
	def remove_extra_spaces!
		self.gsub!(/\s+/, " ").gsub!(/\s+,/, ",").strip!
			.gsub!(/^,/, "").gsub!(/,\z/, "").strip!
			.gsub!(/,+/, ",")
	end

	def remove_extra_spaces
		self.gsub(/\s+/, " ").gsub(/\s+,/, ",").strip
			.gsub(/^,/, "").gsub(/,\z/, "").strip
			.gsub(/,+/, ",")
  end
  
  def is_number?
    true if Float(self) rescue false
  end
end