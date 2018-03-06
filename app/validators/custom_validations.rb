module CustomValidations
	def self.inclusion(_class, attribute, array)
	  _class.validates attribute,
	    inclusion: { 
	      in: array, 
	      message: "must be included in #{array.log_format}" 
	    },
	    allow_nil: true
	end
end