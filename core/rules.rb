module Cedilla
  
  class Rules
  
    attr_reader :genres, :content_types, :minimum_citation_groups
  
    def initialize()
      conf = YAML.load_file('./config/rules.yaml')
      
      @genres = conf['genres'].collect{ |key,val| "#{key}" }
      @content_types = conf['content_types'].collect{ |key,val| "#{key}" }
      @minimum_citation_groups = conf['minimum_citation_groups'].collect{ |key,val| "#{key}" }
      
      @genre_matches = conf['unknown_genres'] #.map{ |key,val| @genre_matches["#{key}"] = "#{val}" }
      
      @genre_services = conf['genres']
      @content_type_services = conf['content_types']
      @minimum_citation_group_services = conf['minimum_citation_groups']
    end
  
    # Retrieve the list of services that can process the given content_type and genre
    def get_available_services(content_type, genre)
      @content_type_services[content_type].keep_if{ |item| @genre_services[genre].include?(item) }
    end
    
    # Determine whether or not the specified service can be dispatched with the given citation
    def can_dispatch(service_name, citation_group)
      
    end
    
    # Attempt to translate the genre into one of the known genres
    def translate_genre(unknown_genre)
      @genre_matches[unknown_genre]
    end
    
    # Determine what the minimum citation group is for the given citation
    def get_minimum_citation_group(citation)
      
    end
    
  end
  
end