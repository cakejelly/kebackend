require 'sinatra'
require './app'

Dotenv.load

run Sinatra::Application
