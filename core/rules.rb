module Cedilla
  
  class Rules
  
    attr_reader :genres, :content_types, :minimum_citation_groups
  
    def initialize()
      conf = YAML.load_file("#{Cedilla::Aggregator::CONFIG_PATH}/rules.yaml")
      
      @genres = conf['genres'].collect{ |key,val| "#{key}" }
      @content_types = conf['content_types'].collect{ |key,val| "#{key}" }
      @minimum_citation_groups = conf['minimum_citation_groups'].collect{ |key,val| "#{key}" }
      
      @genre_matches = conf['unknown_genres'] #.map{ |key,val| @genre_matches["#{key}"] = "#{val}" }
      
      @genre_services = conf['genres']
      @content_type_services = conf['content_types']
      @minimum_citation_group_properties = conf['minimum_citation_groups']
    end
  
# --------------------------------------------------------------------------------------------------------------------
# Retrieve the list of services that can process the given content_type and genre
# --------------------------------------------------------------------------------------------------------------------
    def get_available_services(citation)
      # Grab the list of services available for the citation's genre and content type
      ret = []
      ret = @content_type_services[citation.content_type].clone unless @content_type_services[citation.content_type].nil?

      ret = ret.keep_if{ |item| @genre_services[citation.genre].include?(item) unless @genre_services[citation.genre].nil? } unless ret.empty?
      ret
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the specified service can be dispatched for the given citation
# --------------------------------------------------------------------------------------------------------------------
    def can_dispatch_to_service?(service_name, citation)
      # If the citation's genre and content type are defined
      unless @content_type_services["#{citation.content_type}"].nil? or @genre_services["#{citation.genre}"].nil?  
        # If the service appears in the list of valid services for both the citation's genre and content type
        @content_type_services["#{citation.content_type}"].include?(service_name) and 
                                                @genre_services["#{citation.genre}"].include?(service_name)
      else
        false
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Attempt to translate the genre into one of the known genres
# --------------------------------------------------------------------------------------------------------------------
    def translate_genre(unknown_genre)
      @genre_matches[unknown_genre]
    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Determine whether or not the citation has the minimum information
# --------------------------------------------------------------------------------------------------------------------
    def has_minimum_citation_requirements?(citation)
      if citation.valid?
        rules = @minimum_citation_group_properties["#{citation.genre}"] 
        rets = []
       
        unless rules.nil?
          # AND options
          rules.each do |rule|
            if rule.is_a?(Array)
              # These are OR options so loop through the array, if one is true they are all true
              rets << (rule.collect{ |subrule| 
                if subrule == 'IDENTIFIER'
                  citation.has_identifier?
                
                else
                  (!citation.method("#{subrule}").call.nil? or !citation.method("#{subrule}").call == '') if citation.respond_to?("#{subrule}") 
                end
              }.include?(true))

            else
              # This is a single item so just check to see if it has a value
              if rule == 'IDENTIFIER'
                rets << !citation.has_identifier?
              else
                rets << (!citation.method("#{rule}").call.nil? or !citation.method("#{rule}").call == '') if citation.respond_to?("#{rule}")
              end
            end
          end
        
        end # rules.nil?
      
        # If no rules were validated or ANY one of the AND options failed, its false
        !rets.empty? and !rets.include?(false)
        
      else # citation.valid?
        false
      end
    end
    
  end
  
end