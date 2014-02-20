module Cedilla
  
  class Citation
    
    attr_accessor :genre, :content_type
    
    attr_accessor :resources
    
    # These items are updated by the services and sent back to the requestor (- quick_link is the best electronic copy of the item )
    attr_accessor :subject, :cover_image, :abstract, :quick_link
    
    # Identifiers
    attr_accessor :issn, :eissn, :isbn, :eisbn, :oclc, :lccn, :doi
    attr_accessor :svc_specific_id_1, :svc_specific_id_2, :svc_specific_id_3
    
    # Titles
    attr_accessor :title, :article_title, :journal_title, :book_title, :short_title
    
    # Author attributes
    attr_accessor :author_full_name, :author_last_name, :author_first_name, :author_suffix
    attr_accessor :author_middle_initial, :author_first_initial, :author_initials, :author_organization
    
    # Publisher attributes
    attr_accessor :publisher, :publication_date, :publication_place, :publication_date
    
    # Detailed search attributes
    attr_accessor :date, :volume, :issue, :article_number, :enumeration, :season, :quarter, :part, :edition
    attr_accessor :start_page, :end_page, :pages
    
    # This attribute is meant to store undefined citation parameters that came in from the client
    attr_accessor :others 

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params = {})
      @others = Set.new  # Set prevents duplicates automatically
      @resources = Set.new  # Set prevents duplicates automatically!
      
      # Assign the appropriate params to their attributes, place everything else in others
      params.each do |key,val|
        if self.respond_to?("#{key}=")
          self.method("#{key}=").call(val)
        else
          self.others << "#{key}=#{val}"
        end
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Establish the primary key for the object: identifiers and titles
# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      return false unless object.is_a?(self.class)
    
      self.identifiers == object.identifiers and self.title == object.title and self.journal_title == object.journal_title and
      self.book_title == object.book_title and self.article_title == object.article_title
    end

# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation is valid
# --------------------------------------------------------------------------------------------------------------------
    def valid?
      # A Citation MUST have a genre and a content type
      !@genre.nil? and @genre != '' and !@content_type.nil? and @content_type != ''
    end

# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation has an identifier
# --------------------------------------------------------------------------------------------------------------------    
    def has_identifier?
      (!@issn.nil? and @issn != '') or (!@eissn.nil? and @eissn != '') or (!@isbn.nil? and @isbn != '') or 
        (!@eisbn.nil? and @eisbn != '') or (!@oclc.nil? and @oclc != '') or (!@lccn.nil? and @lccn != '') or 
        (!@doi.nil? and @doi != '') or (!@svc_specific_id_1.nil? and @svc_specific_id_1 != '') or 
        (!@svc_specific_id_2.nil? and @svc_specific_id_2 != '') or (!@svc_specific_id_3.nil? and @svc_specific_id_3 != '')
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Determine whether the resource exists.
# --------------------------------------------------------------------------------------------------------------------
    def has_resource?(resource)
      ret = false
      self.resources.each{ |rsc| ret = true if rsc == resource }
      ret
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Return all of the identifiers for the citation
# --------------------------------------------------------------------------------------------------------------------
    def identifiers
      {'issn' => @issn, 'eissn' => @eissn, 'isbn' => @isbn, 'eisbn' => @eisbn, 'oclc' => @oclc, 'lccn' => @lccn, 'doi' => @doi,
           'svc_specific_id_1' => @svc_specific_id_1, 'svc_specific_id_2' => @svc_specific_id_2, 'svc_specific_id_3' => @svc_specific_id_3}
    end
    
# ---------------------------------------------------------------------------------------------------
# Determine whether or not the 
# ---------------------------------------------------------------------------------------------------
    def dispatchable?
      Cedilla::Rules.new.has_minimum_citation_requirements?(self)
    end

# --------------------------------------------------------------------------------------------------------------------
    def to_s
      "genre: '#{@genre}', content_type: '#{@content_type}', " + identifiers.select{ |x,y| !y.nil? }.map{ |x,y| "#{x}: '#{y}'" }.join(', ')
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Override the basic to_json method
# --------------------------------------------------------------------------------------------------------------------
    def to_hash
      ret = {}
      
      self.methods.each do |method|
        name = method.id2name.gsub('=', '')
        val = self.method(name).call if method.id2name[-1] == '=' and self.respond_to?(name)  
        ret["#{name}"] = val unless val.nil? or ['!', 'others', 'resources'].include?(name)
      end
      
      ret["resources"] = self.resources.collect { |resource| resource.to_hash }
      
      ret
    end
    
  end
end