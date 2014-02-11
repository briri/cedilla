module Cedilla
  
  class Resource
    
    attr_reader :citation
    
    attr_accessor :source, :location, :target
    
    attr_accessor :local_id, :format, :type, :description, :catalog_url
    
    attr_accessor :availability, :status
    
    def initialize(citation = nil)
      @citation = citation.is_a?(Cedilla::Citation) ? citation : Cedilla::Citation.new
    end
    
    
    
  end
  
end