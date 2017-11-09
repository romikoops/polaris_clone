class Tenant < ApplicationRecord
    has_many :routes
    has_many :hubs
    has_many :routes
    has_many :users
end
