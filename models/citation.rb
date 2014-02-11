module Cedilla
  
  class Citation
    
    attr_accessor :genre, :content_type
    
    # These items are updated by the services and sent back to the requestor (- quick_link is the best electronic copy of the item )
    attr_accessor :subject, :cover_image, :synopsis, :quick_link
    
    # Identifiers
    attr_accessor :issn, :eissn, :isbn, :eisbn, :oclc, :lccn, :doi
    attr_accessor :svc_specific_id_1, :svc_specific_id_2, :svc_specific_id_3
    
    attr_accessor :title, :article_title, :journal_title, :book_title, :short_title
    
    attr_accessor :author_full_name, :author_last_name, :author_first_name, :author_suffix, :author_organization
    attr_accessor :author_middle_initial, :author_first_initial, :author_initials
    
    attr_accessor :publisher, :publication_date, :publication_place, :publication_date
    
    attr_accessor :date, :volume, :issue, :article_number, :enumeration, :season, :quarter, :part, :edition
    attr_accessor :start_page, :end_page, :pages
    
    attr_accessor :others # This attribute is meant to store undefined citation parameters that came in from the client

    attr_accessor :resources

    def initialize
      @others = []
      @resources = []
    end

# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation is valid
# --------------------------------------------------------------------------------------------------------------------
    def valid?
      # A Citation MUST have a genre and a content type
      ret = (!@genre.nil? and @genre != '' and !@content_type.nil? and @content_type != '')

      # A Citation MUST have at least one Identifier or at least one title
      ret = ((self.has_identifier?) or
                  (!@title.nil? and @title != '') or (!@article_title.nil? and @article_title != '') or 
                  (!@journal_title.nil? and @journal_title != '') or (!@book_title.nil? and @book_title != '')) if ret
      ret
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
# Return all of the identifiers for the citation
# --------------------------------------------------------------------------------------------------------------------
    def identifiers
      {'issn' => @issn, 'eissn' => @eissn, 'isbn' => @isbn, 'eisbn' => @eisbn, 'oclc' => @oclc, 'lccn' => @lccn, 'doi' => @doi,
           'svc_specific_id_1' => @svc_specific_id_1, 'svc_specific_id_2' => @svc_specific_id_2, 'svc_specific_id_3' => @svc_specific_id_3}
    end
    
  end
end