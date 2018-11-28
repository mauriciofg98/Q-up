require 'data_mapper' # metagem, requires common plugins too.

class User
    include DataMapper::Resource
    property :id, Serial
    property :created_at, DateTime

    property :haircut, Boolean, default => false
    property :head_shave, Boolean, default => false
    property :beard_trim, Boolean, default => false
    property :beard_shave, Boolean, default => false

    property :barber_choice, Serial

    property :name, String

    property :administrator, Boolean, :default => false

    def login(password)
    	return self.password == password
    end
end