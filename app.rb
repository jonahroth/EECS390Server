require 'sinatra'
require 'sinatra/activerecord'
require "sinatra/reloader" if development?
require 'json'
require 'bcrypt'
require 'net/http'
require 'uri'
require 'csv'

Dir['./config/*.rb'].each {|file| require file}
Dir['./models/*.rb'].each {|file| require file}
require './app/pre.rb'
require './app/helpers.rb'
Dir['./app/*.rb'].each {|file| require file}
