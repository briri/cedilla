module Cedilla
  
  class Broker
      
    def initialize
      @factory = Cedilla::ServiceFactory.new
      @rules = Cedilla::Rules.new
    end
      
    def negotiate(client_id, citation, broadcaster)
      services = @rules.get_available_services(citation)
      completed = []
      
      # Start an EventMachine for the dispatch process
      EventMachine.run do
        
        # Heartbeat to check to see if the services are complete
        timer = EventMachine::PeriodicTimer.new(3) do 
          puts "tic"
          puts "processing complete" if completed.count == services.count
          
          # TODO: This EM.stop command may be problematic once we tie this into the controller!!!!!
          EventMachine.stop if completed.count == services.count
          timer.cancel if completed.count == services.count
        end 
        
        # Call each service via EventMachine's defer method. This allows the calls to made asyncronously
        services.each do |service|
          svc = @factory.create(service)
          
          operation = proc { |prc| svc.submit(citation) }
          
          callback = proc do |result| 
            #TODO: Enhance the citation
            #enahance_citation(result)
            
            puts "reached callback for #{service}- got #{result}"
            broadcaster.broadcast(client_id, result) 
            completed << service unless completed.include?(service)
          end
          
          # If the citation has enough information for the service
          if @rules.can_dispatch_to_service?(service, citation)
            begin
              
              puts "deferring call to #{service}"
              
              # Dispatch each service as a deferable event so that they can run simultaneously
              EventMachine.defer(operation, callback) 
              
            rescue Exception => e
              # If we are supposed to try again, do so otherwise send the error back
              # TODO: This will actually dispatch everything! we just want to do one individual service
              #if svc.attempts <= svc.max_attempts
                puts "error in broker.negotiate, but trying again for #{service}: #{e.message}"
              #  self.negotiate(client_id, citation, broadcaster)
                
              #else
                broadcaster.broadcast(client_id, [e.message])
                puts "error in broker.negotiate: #{e.message}"
              #end
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