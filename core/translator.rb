require 'json'

module Cedilla
  
  class Translator
    
# --------------------------------------------------------------------------------------------------------------------
# Uses the translation mapping file to parse the query string into a Citation object
# --------------------------------------------------------------------------------------------------------------------
    def self.query_string_to_citation(service_translation, query_string)
      hash = {}; ids = {}
      config = load_config(service_translation).invert
      
      # Parse the openurl query string into a hash
      query_string.to_s.split('&').each do |item|
        key_vals = item.split('=')
        hash["#{key_vals[0]}"] = key_vals[1]
      end
      
      citation = Cedilla::Citation.new
      
      # If a translation service was defined, use it to find the correct the properties
      unless config.empty?        
        hash.each do |key,val| 
          if citation.respond_to?("#{config[key]}=")
            citation.method("#{config[key]}=").call(URI.unescape(val))  
  
          else            
            # If the citation object doesn't understand the parameter, just stuff it into the others array
            citation.others << "#{config[key].nil? ? key : config[key]}=#{URI.unescape(val)}"
          end
        end 
        
      else        
        # Else just try to match the property names to items in the query string
        hash.each do |key,val| 
          if citation.respond_to?("#{key}=")
            citation.method("#{URI.unescape(key)}=").call(URI.unescape(val))  
          else
            # If the citation object doesn't understand they parameter, just stuff it into the others array
            citation.others << "#{URI.unescape(key)}=#{URI.unescape(val)}"
          end
        end
      end
      
      citation
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Uses the translation mapping file to generate a query string from the Citation object
# --------------------------------------------------------------------------------------------------------------------
    def self.citation_to_query_string(service_translation, citation)
      unless citation.nil?
        config = load_config(service_translation)
        query = ""
        
        # Convert the citation's properties into a query string using the paramater names provided in the config file
        unless config.empty?
          config.map do |key,val| 
            if citation.respond_to?("#{key}")
              query += "&#{URI.escape(val)}=#{URI.escape(citation.method("#{key}").call)}" unless citation.method("#{key}").call.nil? 
            end
          end
          
        else
          # no translation file was provided so just dump the citation's propeties out to the query string
          citation.methods.keep_if{ |symb| symb.id2name[-1] == '=' and symb.id2name != '!=' }.each do |attr|
            prop = attr.to_s.gsub('=', '')
            
            if citation.respond_to?("#{prop}") and prop != 'others'
              query += "&#{URI.escape(prop)}=#{URI.escape(citation.method("#{prop}").call.to_s)}" unless citation.method("#{prop}").call.nil? 
            end
          end
          
        end
        
        # Dump the 'others' array as-is
        query += '&' + citation.others.collect{ |item| "#{URI.escape(item)}"}.join('&') unless citation.others.nil?
        
        query[1..query.length]
        
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Convert the JSON input into a Citation object
# --------------------------------------------------------------------------------------------------------------------
    def self.json_to_citation(json)
      Cedilla::Citation.new
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Convert the JSON input into an Array of resource Objects
# --------------------------------------------------------------------------------------------------------------------
    def self.json_to_resources(resources)
      [Cedilla::Resource.new]
    end

# --------------------------------------------------------------------------------------------------------------------
# Convert the Citation object to JSON
# --------------------------------------------------------------------------------------------------------------------    
    def self.citation_to_json(citation)
      Cedilla::Citation.new.to_json
    end

# --------------------------------------------------------------------------------------------------------------------
# Convert the Array of Resource Objects into JSON
# --------------------------------------------------------------------------------------------------------------------    
    def self.resources_to_json(resources)
      [Cedilla::Resource.new].to_json
    end
    
private
    def self.load_config(config_name)
      path = "#{Cedilla::Aggregator::TRANSLATION_PATH}/#{config_name.downcase}.yaml"
      File.exists?(path) ? YAML.load_file(path) : {}
    end
    
  end
  
end