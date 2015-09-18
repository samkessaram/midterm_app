require 'rubygems'
require 'bundler/setup'

require 'active_support/all'

# Load Sinatra Framework (with AR)
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib/all' # Requires cookies, among other things
require 'oauth'
require 'twitter'
require 'pry'

APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s
@@CONSUMER_KEY="RVUFX59IzYpwchFJ58bk6kSKK"
@@CONSUMER_SECRET="sMSiCm3fNs16sbdmAQDW0kDjRkB9u6cIWx57WUNozBNdo8Tkr0"
@@CALLBACK_URL="http://example.org/oauth/callback"

# Sinatra configuration
configure do

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
