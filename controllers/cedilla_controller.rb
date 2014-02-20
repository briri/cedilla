require 'sinatra/streaming'

module Cedilla

  class Aggregator < Sinatra::Application
   
# Primary SSE route into the Delivery Aggregator program
    get '/stream', :provides => 'text/event-stream' do
      response['Cache-Control'] = 'no-cache'
      response['Connection'] = 'keep-alive'
      
      # Start EventMachine
      stream(:keep_open) do |out|
        client_id = @@broadcaster.register(out)
      
        out.callback { puts "in callback for #{client_id}, might be a good place to stash the json into a cache" }  # This happens once the out.close method is called
      
        out.errback { puts "in errback for #{client_id}" } # This happens after out.callback fires for some reason
        
        # Generate a citation from the openurl passed in
        citation = Cedilla::Translator.query_string_to_citation('open_url', request.query_string)
        
        # Create a new broker and send it the citation
        broker = Broker.new
        broker.negotiate(client_id, citation, @@broadcaster)
       
        i = 0
        # Setup a timer to check to see if the broker has heard back from all the available services
        timer = EventMachine::PeriodicTimer.new(3) do 
          puts "in timer - complete? #{broker.complete?}"
          
          # If the broker is finished or we have reached the timeout value, disconnect from the client
          if broker.complete? or i >= APP_CONFIG['broker_timeout']
            @@broadcaster.unregister(client_id) 
            timer.cancel
            out.close
          end
          
          i += 1
        end 
      
      end # stream
  
      200
    end
    
  end
  
end