module Cedilla
  
  class Citation
    
    attr_accessor :genre, :content_type
    
    # These items are updated by the services and sent back to the requestor (- quick_link is the best electronic copy of the item )
    attr_accessor :subject, :cover_image, :synopsis, :quick_link
    
    attr_accessor :issn, :eissn, :isbn, :oclc, :lccn
    
    attr_accessor :title, :article_title, :journal_title, :book_title, :short_title
    
    attr_accessor :author_full_name, :author_last_name, :author_first_name, :author_suffix, :author_organization
    attr_accessor :author_middle_initial, :author_first_initial, :author_initials
    
    attr_accessor :date, :volume, :issue, :article_number, :enumeration, :season, :quarter, :part, :start_page, :end_page, :pages
    
    attr_accessor :others # This attribute is meant to store undefined citation parameters that came in from the client

    def initialize
      @others = []
    end

    def has_identifier?
      !@issn.nil? or !@eissn.nil? or !@isbn.nil? or !@oclc.nil? or !@lccn.nil?
    end
    
    def has_title_and_author?
      (!@title.nil? or !@article_title.nil? or !@journal_title.nil? or !@book_title.nil?) and (!@author_full_name.nil? or !@author_last_name.nil?)
    end
    
  end
  
end