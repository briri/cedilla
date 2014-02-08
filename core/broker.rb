module Cedilla
  
  class Broker
      
    def initialize
      @factory = Cedilla::ServiceFactory.new
      @rules = Cedilla::Rules.new
    end
      
    def negotiate(client_id, citation, broadcaster)
      services = @rules.get_available_services(citation.content_type, citation.genre)
      
      nbr_processed = 0 
      
      # Start an EventMachine for the dispatch process
      EventMachine.run do
        # Call each service via EventMachine's defer method. This allows the calls to made asyncronously
        services.each do |service|
          
          operation = proc do |prc| 
            service.search(citation) 
          end
          
          callback = proc do |result| 
            enahance_citation(result)
            broadcaster.publish(client_id, result) 
          end
        
          # If the citation has enough information for the service
          if @rules.can_dispatch(service.name, citation.group)
            begin
              # Dispatch each service as a deferable event so that they can run simultaneously
              EventMachine.defer(operation, callback) 
              
            rescue Exception => e
              # If we are supposed to try again, do so otherwise send the error back
              if service.attempts <= service.max_attempts
                puts "error in broker.negotiate, but trying again for #{service.name}: #{e.message}"
                self.negotiate(client_id, citation, broadcaster)
                
              else
                broadcaster.publish(client_id, [e.message])
                puts "error in broker.negotiate: #{e.message}"
              end
            end
            
          else
            # If the other services have not yet completed, sleep and then check again
            # Another service may have been able to enhance the citation enough
            if nbr_processed == services.count - 1
              sleep(Cedilla::APP_CONFIG['broker_sleep_length'])
              self.negotiate(client_id, citation, broadcaster)
            end
          end

        end # @service.each
        
      end # EventMachine.run
      
    end
      
  end
  
end