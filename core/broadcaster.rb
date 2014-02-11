module Cedilla
  
  class Broadcaster
    
    def initialize
      @clients = {}
    end
    
# ----------------------------------------------------------------------------------
# Add the connection to the hash and return the id
# ----------------------------------------------------------------------------------
    def register(connection = nil)
      client_id = SecureRandom.uuid
      @clients["#{client_id}"] = connection
      client_id.to_s
    end
    
# ----------------------------------------------------------------------------------
# Removes the connection
# ----------------------------------------------------------------------------------
    def unregister(client_id)
      @clients.delete(client_id)
    end
    
# ----------------------------------------------------------------------------------
# See if the client_id or connection object is already registered
# ----------------------------------------------------------------------------------
    def registered?(item)
      @clients.has_key?(item) or @clients.has_value?(item)
    end

# ----------------------------------------------------------------------------------    
# Publishes the supplied resources to the specified client
# ----------------------------------------------------------------------------------
    def broadcast(client_id, *items)
      client = @clients[client_id]
      
      # If the client is still subscribed broadcast the information
      unless client.nil?
        items.each do |item|
          
          if item.is_a?(Cedilla::Citation)
            client << Cedilla::Translator.citation_to_json(item)
            
          elsif item.is_a?(Cedilla::Resource)
              client << Cedilla::Translator.resource_to_json(item)
              
          else
            client << item.to_s
          end
          
        end
        
        return true
        
      else
        return false
      end
      
    end
    
  end
  
end