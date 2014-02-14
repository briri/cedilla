module Cedilla
  
  class Citation
    
    attr_accessor :genre, :content_type
    
    attr_accessor :resources
    
    # These items are updated by the services and sent back to the requestor (- quick_link is the best electronic copy of the item )
    attr_accessor :subject, :cover_image, :synopsis, :quick_link
    
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
    def initialize(params)
      @others = []
      @resources = []
      
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
    
    def to_json
      # TODO: reformat this so we don't pass nulls!!
      
      {:genre => @genre, :content_type => @content_type,
       :subject => @subject, :cover_image => @cover_image, :synopsis => @synopsis,  
       :issn => @issn, :eissn => @eissn, :isbn => @isbn, :eisbn => @eisbn, :oclc => @oclc, :lccn => @lccn, :doi => @doi,
       :svc_specific_ids => [@svc_specific_ids, @svc_specific_id_2, @svc_specific_id_3],
       :title => @title, :article_title => @article_title, :journal_title => @journal_title, :book_title => @book_title, :short_title => @short_title,
       :publisher => @publisher, :publication_date => @publication_date, :publication_place => @publication_place, :publication_date => @publication_date,
       :date => @date, :volume => @volume, :issue => @issue, :article_number => @article_number, :enumeration => @enumeration, :season => @season, 
       :quarter => @quarter, :part => @part, :edition => @edition, :start_page => @start_page, :end_page => @end_page, :pages => @pages}
    end
    
  end
end