ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = "sqlite::memory:"
$LOAD_PATH.unshift(File.absolute_path(File.join(File.dirname(__FILE__), '../')))
require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)
require 'test/unit'
require 'cedilla'

def broker_proxy(client_id, citation, broadcaster)
  broker = Cedilla::Broker.new
  
  EventMachine.run do
    broker.negotiate(client_id, citation, broadcaster)
    
    i = 0
    # Setup a timer to check to see if the broker has heard back from all the available services
    timer = EventMachine::PeriodicTimer.new(1) do 
      # If the broker is finished or we have reached the timeout value, disconnect from the client
      if broker.complete? or i >= Cedilla::Aggregator::APP_CONFIG['broker_timeout']
        timer.cancel
        EventMachine.stop
      end
      
      i += 1
    end 
  end
  
end