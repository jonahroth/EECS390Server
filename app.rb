require 'sinatra'
require 'sinatra/activerecord'
require "sinatra/reloader" if development?
require 'json'
require 'bcrypt'
Dir['./config/*.rb'].each {|file| require file}
Dir['./models/*.rb'].each {|file| require file}
Dir['./app/*.rb'].each {|file| require file}
