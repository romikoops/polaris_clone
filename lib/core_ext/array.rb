class Array
	def log_format
		self.to_s.gsub("\"", "'")
	end
  def sql_format
    "(#{self.join(', ')})"
  end
end