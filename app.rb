require "sinatra"
require_relative "authentication.rb"
require "sinatra/flash"

enable :sessions

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

class Barber
	include DataMapper::Resource

	property :id, Serial
	property :name, Text
	#fill in the rest
end

DataMapper.finalize
User.auto_upgrade!
Barber.auto_upgrade!

#make an admin user if one doesn't exist!
if User.all(administrator: true).count == 0
	u = User.new
	u.email = "admin@admin.com"
	u.password = "admin"
	u.administrator = true
	u.save
end

hello = Barber.new
hello.name = "isai maldonado"
hello.save
#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	
	erb :index
end

post "/one" do
	@barbers = Barber.all
	erb :index2
end
post "/two" do 
	
	barberChoice = params["barber"]
	erb :index3
end

post "/three" do
 	erb :index4
end

post "/queue" do
	
end

get "/admin" do 
	redirect "/login"
end


get "/admin1" do
	flash[:success] = "succesfully logged in"
	erb :admin, :layout => :admin_layout
end

post "/admin1/addbarber" do 
	if params["name"]
		b = Barber.new
		b.name = params["name"]
	
		b.save
		return "succesful"
	else
		return "missing information"
	end
end	

get "/admin1/new" do
	authenticate!
	if current_user.administrator 
	erb :new_barber, :layout => :admin_layout
else 
	redirect "/login"
end
end
