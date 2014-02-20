require 'json'

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
    def broadcast(client_id, service_name, final = false, *items)
      client = @clients[client_id]
      
      message = "\"request_id\":\"#{(final ? '1' : client_id)}\",\"time\":\"#{Time.now}\",\"service\":\"#{service_name}\""
      
      # If the client is still subscribed broadcast the information
      unless client.nil?
        items.each do |item|
          
          if item.is_a?(Cedilla::Citation)
            message += ",\"citation\":#{item.to_hash}"
            
          elsif item.is_a?(Cedilla::Resource)
            message += ",\"resource\":#{item.to_hash}"
              
          elsif item.is_a?(Hash)
            item.map{ |x,y| message += ",\"#{x.to_s}\":\"#{y.to_s}\"" }
            
          else
            message += ",\"message\":\"#{item.to_s}\""
          end
          
        end
        
        client << "id: #{client_id}\nretry: 10000\ndata: {#{message.gsub('=>', ':')}}\n\n"
        
        return true
        
      else
        return false
      end
      
    end
    
  end
  
end