class TransportCategory < ApplicationRecord
	LOAD_TYPE_CARGO_CLASSES = {
		'container' => %w(
			fcl_20f
	    fcl_40f
	    fcl_40f_hq
		),
		'cargo_item' => %w(
			lcl
		)
	}
	LOAD_TYPES = LOAD_TYPE_CARGO_CLASSES.keys

	belongs_to :vehicle

	before_validation :set_load_type
	
	validates :cargo_class, presence: true

	LOAD_TYPES.each do |_load_type|
		validates :cargo_class, 
			inclusion: { 
	      in: LOAD_TYPE_CARGO_CLASSES[_load_type], 
	      message: "must be included in [#{LOAD_TYPE_CARGO_CLASSES[_load_type].join(', ')}]" 
	    }, 
	    if: -> { self.load_type == _load_type }

	  # This allows the following example usage for every load type: 
	  # TransportCategory.container_load_type #=> collection of TransportCategory instances
  	scope "#{_load_type}_load_type".to_sym, -> { where(load_type: _load_type) }
  end
  
  # This allows the following example usage: 
  # TransportCategory.load_type("container") #=> collection of TransportCategory instances
  scope :load_type, -> _load_type { where(load_type: _load_type) }

	validates :load_type, 
		presence: true, 
		inclusion: { 
      in: LOAD_TYPES, 
      message: "must be included in [#{LOAD_TYPES.join(', ')}]" 
    }

	private

	def set_load_type
		LOAD_TYPES.each do |_load_type|
			self.load_type = _load_type if cargo_class_is_from?(_load_type)
		end
	end

	def cargo_class_is_from?(load_type)
		LOAD_TYPE_CARGO_CLASSES[load_type].include?(cargo_class)
	end
end
