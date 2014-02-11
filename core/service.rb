module Cedilla
  
  class Service
    include EventMachine::Deferrable
    
    attr_reader :disabled, :max_attempts, :base_url, :config
    
    attr_accessor :base_query_string, :errors

# ---------------------------------------------------------------------------------------------------
# Intended to be overwritten by the implementing service
# ---------------------------------------------------------------------------------------------------
    def process(response)
      
    end

    def build_target
    
    end
    
# ---------------------------------------------------------------------------------------------------
    def initialize(config)
      @errors = {}
      
      if config.is_a?(Array) 
        @disabled = config['disabled'] == 'true' || false
        @max_attempts = config['max_attempts'].to_i || 1
        @base_query_string = config['url_query']
        @translator = Cedilla::Translator.new(config['translator'])
        
        @config = config.delete_if{ |item|['disabled', 'max_attempts', 'base_query', 'translator', 'query'].include?(item) }
        
        if config.include?('base_url')
          @base_url = config['base_url']
          
        else
          @errors["Initialization"] = 'Cedilla cannot dispatch to this service because no base_url was defined in the configuration file! '
        end  
      end
      
    end

# ---------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------    
    def submit(citation)
      
    end
    
    
  end
  
end