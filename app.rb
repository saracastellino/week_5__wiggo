require('sinatra')
require('sinatra/contrib/all') if development?
require_relative('controllers/guests_controller')
require_relative('controllers/properties_controller')
require_relative('controllers/bookings_controller')

get '/' do
  erb(:index)
end
