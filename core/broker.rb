module Cedilla
  
  class Broker
    
    def initialize
      @factory = Cedilla::ServiceFactory.new
      @rules = Cedilla::Rules.new
      
      @service_count = 0
      @completed = []
    end
      
# --------------------------------------------------------------------------------------      
# Dispatch the appropriate services for the citation
# --------------------------------------------------------------------------------------
    def negotiate(client_id, citation, broadcaster)
      services = @rules.get_available_services(citation)
      @service_count = services.count
      
      # If the citation's genre and content type have no matching services mark the termination flag and send back an empty json
      @no_services_available = true if services.count == 0
      
      # If the citation was valid and we had services that respond to its genre and content_type
      if citation.valid? and !@no_services_available
        # Start an EventMachine for the dispatch process
        EventMachine.run do
        
          # Call each service via EventMachine's defer method. This allows the calls to made asyncronously
          services.each do |service|
            svc = @factory.create(service)

            operation = proc { |prc| svc.submit(citation) }
          
            callback = proc do |result| 
              # If the service returned a citation, augment the original citation
              augment_citation(citation, result) if result.is_a?(Cedilla::Citation)
            
              @completed << service unless @completed.include?(service)
            
              # If we received a citation back from the service, pass the augmented citation to the broadcaster otherwise just send the result
              #Thread.new { 
                broadcaster.broadcast(client_id, service, self.complete?, (result.is_a?(Cedilla::Citation) ? citation : result)) 
              #}

puts "\nreached callback for #{service}- got #{citation} #{EM.defers_finished?}"
            end
          
            # If the citation has enough information for the service
            if @rules.can_dispatch_to_service?(service, citation)
              begin
                # Dispatch each service as a deferable event so that they can run simultaneously
                EventMachine.defer(operation, callback) 
              
              rescue Exception => e
                # If we are supposed to try again, do so otherwise send the error back
                # TODO: This will actually dispatch everything! we just want to do one individual service
                #if svc.attempts <= svc.max_attempts
                #  self.negotiate(client_id, citation, broadcaster)
                
                #else
                  broadcaster.broadcast(client_id, service, self.complete?, [e.message])
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
      
      else
        broadcaster.broadcast(client_id, nil, self.complete?, nil, {:error => Cedilla::Aggregator::APP_CONFIG['broker_bad_citation_message']})
      end # citation.valid?
      
    end

# --------------------------------------------------------------------------------------
# Determines whether or not the negotiate process has completed
# --------------------------------------------------------------------------------------    
    def complete?
      (@completed.count >= @service_count and @service_count > 0) or @no_services_available
    end
     
# --------------------------------------------------------------------------------------
# Append new citation and resource information onto the original citation
# --------------------------------------------------------------------------------------
    def augment_citation(old_citation, new_citation)
      # Select the attributes from the new citation
      new_citation.methods.select{ |m| m.id2name[-1] == '=' }.each do |method|
        name = method.id2name.gsub('=', '')
        
        # If the item is others or resouorces, add any new items to the original citation
        if ['!', 'others', 'resources', ''].include?(name)
          if name == 'others'
            new_citation.others.each{ |it| old_citation.others << it unless old_citation.others.include?(it) }
          elsif name == 'resources'
            new_citation.resources.each{ |it| old_citation.resources << it unless old_citation.has_resource?(it) }
          end
          
        else
          # Otherwise update the value in the old citation to match the new citation
          old_citation.method(method.id2name).call(new_citation.method(name).call) if old_citation.respond_to?(method.id2name) and 
                                                                        !new_citation.method(name).call.nil? and new_citation.method(name).call != ''
        end
      end
      
      old_citation
    end
    
  end
  
end