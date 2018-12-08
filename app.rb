require "sinatra"
require_relative "authentication.rb"
require "sinatra/flash"
require 'thread'

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
	def wait_list
		return Queueitem.all(bid: id)
	end
end

class Queueitem
	include DataMapper::Resource

	property :id, Serial
	property :name, Text
	property :price, Integer
	property :bid, Integer

	def barber 
		return Barber.get(bid)
	end
end


DataMapper.finalize
User.auto_upgrade!
Barber.auto_upgrade!
Queueitem.auto_upgrade!

#make an admin user if one doesn't exist!
if User.all(administrator: true).count == 0
	u = User.new
	u.email = "admin@admin.com"
	u.password = "admin"
	u.administrator = true
	u.save
end

#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	@barbers = Barber.all
	erb :index
end

get "/Queue" do
	hairtype = params["hairtype"]
	beardtype = params["beardtype"]
	b = Barber.get(params["id"])
	n = params["name"]
	cost = 0
	if hairtype == "Regular Cut" || hairtype == "Full-head shave"
		cost += 15
	elsif hairtype == "Fade Cut"
		cost += 20
	elsif hairtype == "Clean-up"
		cost += 10
	end

	if beardtype != "N/A"
		cost += 10
	end


	q = Queueitem.new
	q.name = n
	q.bid = b.id
	q.price = cost
	q.save
	@cus = q

	erb :index4
end

get "/admin" do 

	authenticate!
	if current_user.administrator 
	@barbers = Barber.all
	erb :admin, :layout => :admin_layout
	#flash[:success] = "succesfully logged in"
	end
	#redirect "/login"
end




post "/admin/addbarber" do 
	if params["name"] != ""
		b = Barber.new
		b.name = params["name"]
	
		b.save
		redirect "/admin"
	else
		flash[:error] = "Must enter a name for new barber "
		redirect "/admin"
	end
end	

get "/admin/new" do
	authenticate!
	if current_user.administrator 
	erb :new_barber, :layout => :admin_layout
	else 
	redirect "/login"
	end
end

get "/admin/delete/:id" do
	authenticate!
	if current_user.administrator 
		b = Barber.get(params[:id])
		b.destroy
		redirect "/admin"
	else
	redirect "/login"
end
end

get "/admin/delete" do
	authenticate!
	if current_user.administrator 
		@barbers = Barber.all
		erb :delete_barber, :layout => :admin_layout
	else
	redirect "/login"
end
end

get "/pop/:id" do
	c = Queueitem.get(params[:id])
	if c != nil
		c.destroy
	end
	redirect "/que"
end

get "/que" do
	@barbers = Barber.all
	erb :view
end
