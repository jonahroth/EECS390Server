require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'bcrypt'
Dir['./config/*.rb'].each {|file| require file}
Dir['./models/*.rb'].each {|file| require file}
Dir['./app/*.rb'].each {|file| require file}


=begin TODO
  Ability to remove users from lobby somehow                        << on hold
  On matchmaking - send data about which emojis are equipped, etc   << on hold - need to know how matchmaking is handled
  Framework for purchasing and storing emojis                       << stretch goal
  Check gamedoc - we need info about all equipment that a user has  << on hold - goes along with matchmaking
  Are package contents handled client side or server side?          << server side
  Will payments be handled through Sinatra server or directly from client UI to Google Play?
  Rank - how is rank calculated? Server side or client? What data needs to get sent back to the server and when?
  Separate powerups/wallpapers so each object is inside its own hash
  System for app to know if item is equipped
=end
