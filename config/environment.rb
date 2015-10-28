require 'rubygems'
require 'bundler/setup'

require 'active_support/all'

# Load Sinatra Framework (with AR)
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib/all' # Requires cookies, among other things
require 'oauth'
require 'twitter'
require 'pry' if development?
require 'chronic'

APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s
@@CONSUMER_KEY="96mMMtccD8TVIiFY0fPq7i9pv"
@@CONSUMER_SECRET="GcTbrbhUIgi25ZGBuESqvmbX8zx3BWRdcn1K9nArxA5Z1xSYSk"
@@CALLBACK_URL="https://antepostapp.herokuapp.com/oauth/callback"

# Sinatra configuration
configure do

  Time.zone = "America/New_York"
  Chronic.time_class = Time.zone
  # ActiveRecord::Base.default_timezone = 'Eastern Time (US & Canada)'

  set :root, APP_ROOT.to_path
  set :server, :puma

  enable :sessions
  set :session_secret, ENV['SESSION_KEY'] || 'lighthouselabssecret'

  set :views, File.join(Sinatra::Application.root, "app", "views")
end

# Set up the database and models
require APP_ROOT.join('config', 'database')

# Load the routes / actions
require APP_ROOT.join('app', 'actions')
