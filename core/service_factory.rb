module Cedilla
  
  class ServiceFactory
    
    attr_reader :names
    
    def initialize
      conf = YAML.load_file('./config/services.yaml')
      
      @names = conf['services'].collect{ |key,val| "#{key}" }
      @service_configs = conf['services']
    end
    
    def create(name)
      conf = @service_configs[name]
      
      # Try to load the service's specific class definition otherwise use the default Service class
      klass = Object.const_defined?("#{name.capitalize}Service") ? Object.const_get("#{name.capitalize}Service") : 
                                                                   Object.const_get("Cedilla").const_get("Service")
      klass.new(conf)
    end
    
  end
  
end