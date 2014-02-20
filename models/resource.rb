module Cedilla
  
  class Resource
    attr_accessor :source, :location, :target
    
    attr_accessor :local_id, :format, :type, :description, :catalog_target
    
    attr_accessor :availability, :status

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params = {})
      # Assign the appropriate params to their attributes, place everything else in others
      params.each do |key,val|
        if self.respond_to?("#{key}=")
          self.method("#{key}=").call(val)
        end
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Establish the primary key for the object: source + location + target
# --------------------------------------------------------------------------------------------------------------------    
  def ==(object)
    if object.is_a?(self.class)
      return (@source == object.source) && (@location == object.location) && (@target == object.target)
    else
      return false
    end
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def to_s
    "source: '#{@source}', location: '#{@location}', target: '#{@target}'"
  end
  
# --------------------------------------------------------------------------------------------------------------------
# Override the basic to_json method
# --------------------------------------------------------------------------------------------------------------------
    def to_hash
      ret = {}
      
      self.methods.select{ |it| it.id2name[-1] == '=' and !['==', '!='].include?(it.id2name) }.each do |method|
        name = method.id2name.gsub('=', '')
        
        if method.id2name[-1] == '=' and self.respond_to?(name)  
          val = self.method(name).call 
          ret["#{name}"] = val if !val.nil? and val != '' and !['!'].include?(name)
        end
      end

      ret
    end
    
  end
  
end