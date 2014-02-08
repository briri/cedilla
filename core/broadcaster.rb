module Cedilla
  
  class Broadcaster
    
    def initialize
      @clients = {}
    end
    
    # Add the connection to the hash and return the id
    def register(connection = nil)
      client_id = SecureRandom.uuid
      @clients["#{client_id}"] = connection
      client_id.to_s
    end
    
    # Removes the connection
    def unregister(client_id)
      @clients.delete(client_id)
    end
    
    # Publishes the supplied resources to the specified client
    def broadcast(client_id, *items)
      
      items.each do |item|
        puts Cedilla::Translator.citation_to_json(item) if item.is_a?(Cedilla::Citation)
        puts Cedilla::Translator.resource_to_json(item) if item.is_a?(Cedilla::Resource)
      end
      
    end
    
  end
  
end