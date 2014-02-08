require 'sinatra'

module Cedilla
  
  class Aggregator < Sinatra::Application
    # Load the configuration files
    APP_CONFIG = YAML.load_file('./config/application.yaml')
    DB_CONFIG = YAML.load_file('./config/database.yaml')
    
    $stdout.puts "Starting #{APP_CONFIG['application_name']}"
    $stdout.puts ".... configuration files loaded"
  
    db_args = {:adapter => DB_CONFIG['db_adapter'],
               :host => DB_CONFIG['db_host'],
               :port => DB_CONFIG['db_port'].to_i,
               :database => DB_CONFIG['db_name'],
               :username => DB_CONFIG['db_username'],
               :password => DB_CONFIG['db_password']}
  
    enable :sessions # enable cookie-based sessions
    set :session_secret, APP_CONFIG['session_secret']
    set :sessions, :expire_after => APP_CONFIG['session_expires']

    # If we're in test mode switch to SQLite and a temp Redis secret
    configure :test do
      db_args = "sqlite::memory:"
      set :session_secret, 'test_redis_secret'
    end
  
    configure :production, :stage do
      enable :logging
    end
  
    set :root, File.dirname(__FILE__)
  
    set server: APP_CONFIG['server_type']
    set :bind, APP_CONFIG['server_host']
    set port: APP_CONFIG['server_port']
  
    # set database
    $stdout.puts ".... establishing connection to #{DB_CONFIG['db_host']}:#{DB_CONFIG['db_name']}"

    #DataMapper.setup(:default, 'sqlite::memory:')
    DataMapper.setup(:default, db_args)

    $stdout.puts ".... loading controllers, models, and services"
    Dir.glob("models/*.rb").each { |r| require_relative r }
    Dir.glob("services/*.rb").each { |r| require_relative r }
    Dir.glob("controllers/*.rb").each { |r| require_relative r }
    Dir.glob("core/*.rb").each { |r| require_relative r }
    Dir.glob("core/mixins/*.rb").each { |r| require_relative r }
    
    # finalize database models
    DataMapper::Logger.new(STDOUT, :debug)
    DataMapper::Model.raise_on_save_failure = true
    DataMapper.finalize.auto_upgrade!
  
    $stdout.puts ".... loading rules"
      
    $stdout.puts ".... creating broadcaster"
    @broadcaster = Cedilla::Broadcaster.new
  
    $stdout.puts ".... initialization complete."
  end
  
end