require 'sinatra'

module Cedilla
  
  class Aggregator < Sinatra::Application
    # If we're in test mode switch to SQLite and a temp Redis secret
    config_path = './config'
    translation_path = './models/translation'
    
    configure :test do
#      db_args = "sqlite::memory:"
      config_path = './test/config'
      translation_path = './test/config/translation'
    end
  
    enable :logging
    set :root, File.dirname(__FILE__)
    
    # Load the configuration files
    CONFIG_PATH = config_path
    TRANSLATION_PATH = translation_path
    APP_CONFIG = YAML.load_file("#{CONFIG_PATH}/application.yaml")
#    DB_CONFIG = YAML.load_file("#{CONFIG_PATH}/database.yaml")
    
    $stdout.puts "Starting #{APP_CONFIG['application_name']}"
    $stdout.puts ".... configuration files loaded from #{CONFIG_PATH}"
    $stdout.puts ".... translation files loaded from #{TRANSLATION_PATH}"
  
#    db_args = {:adapter => DB_CONFIG['db_adapter'],
#               :host => DB_CONFIG['db_host'],
#               :port => DB_CONFIG['db_port'].to_i,
#               :database => DB_CONFIG['db_name'],
#               :username => DB_CONFIG['db_username'],
#               :password => DB_CONFIG['db_password']}
  
    enable :sessions # enable cookie-based sessions
    set :session_secret, APP_CONFIG['session_secret']
    set :sessions, :expire_after => APP_CONFIG['session_expires']

    set server: APP_CONFIG['server_type']
    set :bind, APP_CONFIG['server_host']
    set port: APP_CONFIG['server_port']
  
    # set database
#    $stdout.puts ".... establishing connection to #{DB_CONFIG['db_host']}:#{DB_CONFIG['db_name']}"

    #DataMapper.setup(:default, 'sqlite::memory:')
#    DataMapper.setup(:default, db_args)

    $stdout.puts ".... loading core objects and models"
    Dir.glob("models/*.rb").each { |r| require_relative r }
    Dir.glob("core/mixins/*.rb").each { |r| require_relative r }
    Dir.glob("controllers/*.rb").each { |r| require_relative r }
    Dir.glob("core/*.rb").each { |r| require_relative r }
    Dir.glob("services/*.rb").each { |r| require_relative r }
    
    # finalize database models
#    DataMapper::Logger.new(STDOUT, :debug)
#    DataMapper::Model.raise_on_save_failure = true
#    DataMapper.finalize.auto_upgrade!
  
    $stdout.puts ".... loading rules"
      
    $stdout.puts ".... creating broadcaster"
    @@broadcaster = Cedilla::Broadcaster.new
  
    # TODO: Determine if we need to start EventMachine in a new Thread because the EM git comments state: 
    #       This method blocks calling thread. If you need to start EventMachine event loop from a Web app
    #       running on a non event-driven server (Unicorn, Apache Passenger, Mongrel), do it in a separate thread.
    #
    #Thread.new { EventMachine.run }
  
    $stdout.puts ".... initialization complete."
  end
  
end