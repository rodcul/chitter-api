# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

# Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
# set, when working locally this line will fall back to using SQLite in the
# current directory.
env = ENV['RACK_ENV'] || 'development'
DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/chitter_api_#{env}")

# Define a simple DataMapper model.
class Peep
  include DataMapper::Resource

  property :id, Serial
  property :message, String, :length => 1..140
  property :created_at, DateTime

end

# Finalize the DataMapper models.
DataMapper.finalize

# Tell DataMapper to update the database according to the definitions above.
DataMapper.auto_upgrade!

# To enable cross origin requests for all routes:
configure do
  enable :cross_origin
end

get '/' do
  send_file './public/index.html'
end

# Route to show all peeps, ordered like a blog
get '/peeps' do
  content_type :json
  @peeps = Peep.all(:order => :created_at.desc)

   @peeps.to_json
end

# CREATE: Route to create a new peep
post '/peeps' do
  content_type :json

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  # params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.
  @peep = Peep.new(params)

  if @peep.save
    @peep.to_json
  else
    halt 500
  end
end

# READ: Route to show a specific peep based on its `id`
get '/peeps/:id' do
  content_type :json
  @peep = Peep.get(params[:id].to_i)

  if @peep
    @peep.to_json
  else
    halt 404
  end
end

# UPDATE: Route to update a peep
put '/peeps/:id' do
  content_type :json

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  # params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.

  @peep = Peep.get(params[:id].to_i)
  @peep.update(params)

  if @peep.save
    @peep.to_json
  else
    halt 500
  end
end

# DELETE: Route to delete a peep
delete '/peeps/:id/delete' do
  content_type :json
  @peep = Peep.get(params[:id].to_i)

  if @peep.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end

# If there are no peeps in the database, add a few.
if Peep.count == 0
  Peep.create(:message => "Test peep One")
  Peep.create(:message => "Test peep Two")
end
