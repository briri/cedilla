module Cedilla
  
  class ServiceFactory
    
    attr_reader :names
    
    def initialize
      conf = YAML.load_file("#{Cedilla::Aggregator::CONFIG_PATH}/services.yaml")
      
      @names = conf['services'].collect{ |key,val| "#{key}" }
      @service_configs = conf['services']
    end
    
    def create(service_name)
      conf = @service_configs[service_name]
      
      parts = service_name.split('_')
      name = parts.collect{ |part| "#{part.capitalize}" }.join('')
      
puts "svc name: #{name}"
      
      # Try to load the service's specific class definition otherwise use the default Service class
      klass = Object.const_defined?("#{name}Service") ? Object.const_get("#{name}Service") : Object.const_get("Cedilla").const_get("Service")
      klass.new(conf)
    end
    
  end
  
end