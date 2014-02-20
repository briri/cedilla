require_relative '../test_helper'

class TestCitation < Test::Unit::TestCase

  def setup
    
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    citation = Cedilla::Citation.new({})
    assert citation.resources.empty?, "Was expecting the citations resources to be initialized to an empty array!"
    assert citation.others.empty?, "Was expecting the citations others property to be initialized to an empty hash!"
  end

# --------------------------------------------------------------------------------------------------------    
  def test_equality
    a = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :content_type => 'purchase', :isbn => '1234567890'})
    c = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234'})
    d = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234', :author_last_name => 'Doe'})
    e = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234', :title => 'Example title'})
    
    assert a != b, "Was expecting 2 different citations to evaluate to False!"
    assert a == c, "Was expecting 2 identicial citations to evaluate to True!"
    assert a == d, "Was expecting 2 similar citations to evaluate to True!"
    assert a != e, "Was expecting 2 different citations, 2nd try, to evaluate to False!"
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_valid
    # No genre or content type - should fail
    assert !Cedilla::Citation.new.valid?, "An empty citation should not pass the validation check!"
    
    # No genre - should fail
    assert !Cedilla::Citation.new({:content_type => 'bar'}).valid?, "A citation with no genre should not pass the validation check!"
    
    # No content type - should fail
    assert !Cedilla::Citation.new({:genre => 'foo'}).valid?, "A citation with no content type should not pass the validation check!"
    
    # genre and content type - should pass
    assert Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar'}).valid?, "A citation with a genre and content type should pass the validation check!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_has_identifier
    # Test that it returns false when it has no identifiers
    assert !Cedilla::Citation.new({}).has_identifier?, "Expected there to be no identifiers for an empty citation!"
    assert !Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar'}).has_identifier?, "Expected there to be no identifiers with just genre and content type defined!"
    assert !Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', :title => 'blah'}).has_identifier?, "Expected there to be no identifiers with just genre and content type defined!"
    
    # Test the various identifiers to make sure they each work
    Cedilla::Citation.new.identifiers.each do |key,val|
      assert Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', key => 'blah'}).has_identifier?, "Expected citation to confirm an identifier exists when an #{key} is defined!"
    end
    
    # Test that it returns true when it has multiple identifiers
    assert Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', :issn => 'blah', :isbn => 'yadda'}).has_identifier?, "Expected citation to confirm an identifier exists when multiple identifiers are defined!"
  end
   
# --------------------------------------------------------------------------------------------------------  
  def test_get_identifiers
    # Test to make sure that the identifiers are empty when they should be
    assert !Cedilla::Citation.new({}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers for an empty citation!"
    assert !Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    assert !Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', :title => 'blah'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    
    # Test the various identifiers to make sure they each work
    Cedilla::Citation.new.identifiers.each do |key,val|
      assert_equal 'blah', Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', key => 'blah'}).identifiers[key], "Expected citation to confirm an identifier exists when an #{key} is defined!"
    end
    
    # Test that it returns true when it has multiple identifiers
    citation = Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', :issn => 'blah', :isbn => 'yadda'})
    assert_equal 'blah', citation.identifiers['issn'], "Expected citation to confirm an issn identifier when both the issn and isbn identifiers were defined!"
    assert_equal 'yadda', citation.identifiers['isbn'], "Expected citation to confirm an isbn identifier when both the issn and isbn identifiers were defined!"
  end 

# --------------------------------------------------------------------------------------------------------  
  def test_dispatchable
    # This test is reliant upon the following minimum citation requirement definition be present in test/config/rules.yaml:
    #   minimum_citation_groups:
    #     book:
    #       - ['title', 'book_title', 'IDENTIFIER']
    #     journal:
    #       - ['title', 'journal_title', 'IDENTIFIER']
    #     issue:
    #       - ['title', 'journal_title', 'article_title', 'IDENTIFIER']
    #       - ['volume', 'issue', 'date', 'article_number', 'enumeration', 'season', 'quarter', 'part']
    #     article:
    #       - 'article_title'
    #       - ['title', 'journal_title', 'IDENTIFIER']
    
    assert !Cedilla::Citation.new({}).dispatchable?, "Expected a citation with no genre or content_type to NOT be considered dispatchable!"
    assert !Cedilla::Citation.new({:content_type => 'full_text'}).dispatchable?, "Expected a citation with no genre to NOT be considered dispatchable!"
    assert !Cedilla::Citation.new({:genre => 'book'}).dispatchable?, "Expected a citation with no content_type to NOT be considered dispatchable!"
    
    # Undefined genre - Should pass
    assert Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar'}).dispatchable?, "Expected a citation with a genre and content_type but no special rules for the genre to be considered dispatchable!"
    
    # book - Should require a title OR an identifier
    assert !Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a book with no title or identifier to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => '', :genre => 'book', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a book with a blank title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:isbn => '', :genre => 'book', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a book with a blank identifier to NOT be dispatchable!"
    assert Cedilla::Citation.new({:title => 'Example', :genre => 'book', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a book with a title to be dispatchable!"
    assert Cedilla::Citation.new({:isbn => '1234567890', :genre => 'book', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a book with an identifier to be dispatchable!"
    assert Cedilla::Citation.new({:title => 'Example', :isbn => '1234567890', :genre => 'book', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a book with a title and an identifier to be dispatchable!"
    
    # journal - Should require a title OR an identifier
    assert !Cedilla::Citation.new({:genre => 'journal', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a journal with no title or identifier to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => '', :genre => 'journal', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a journal with a blank title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:isbn => '', :genre => 'journal', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a journal with a blank identifier to NOT be dispatchable!"
    assert Cedilla::Citation.new({:title => 'Example', :genre => 'journal', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a journal with a title to be dispatchable!"
    assert Cedilla::Citation.new({:issn => '1234-6789', :genre => 'journal', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a journal with an identifier to be dispatchable!"
    assert Cedilla::Citation.new({:title => 'Example', :issn => '1234-56789', :genre => 'journal', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a journal with a title and an identifier to be dispatchable!"
    
    # issue - Should require a title OR an identifier AND an issue identifer (like volume)
    assert !Cedilla::Citation.new({:genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with no title or identifier to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => '', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with a blank title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:isbn => '', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with a blank identifier to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => 'Example', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with a title but no volume to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:issn => '1234-6789', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with an identifier but no volume to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:issn => '1234-6789', :volume => '', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with an identifier and a blank volume to NOT be dispatchable!"
    assert Cedilla::Citation.new({:title => 'Example', :volume => 'Spring 2013', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with a title and volume to be dispatchable!"
    assert Cedilla::Citation.new({:issn => '1234-6789', :volume => 'Spring 2013', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with an identifier and volume to be dispatchable!"
    assert Cedilla::Citation.new({:title => 'Example', :issn => '1234-56789', :volume => 'Spring 2013', :genre => 'issue', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a issue with a title and an identifier and volume to be dispatchable!"    

    # article - Should require a title OR an identifier AND an issue identifier (like volume) AND an article title
    assert !Cedilla::Citation.new({:genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with no title or identifier to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => '', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a blank title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:isbn => '', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a blank identifier to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => 'Example', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a title but no volume or article title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:issn => '1234-6789', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with an identifier but no volume or article title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => 'Example', :volume => 'Spring 2013', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a title and volume but no article title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:issn => '1234-6789', :volume => 'Spring 2013', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with an identifier and volume but no article title to NOT be dispatchable!"
    assert !Cedilla::Citation.new({:title => 'Example', :issn => '1234-56789', :volume => 'Spring 2013', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a title and an identifier and volume but no article title to NOT be dispatchable!"    
    assert !Cedilla::Citation.new({:title => 'Example', :issn => '1234-56789', :volume => 'Spring 2013', :article_title => '', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a title and an identifier and volume and a blank article title to NOT be dispatchable!"    
    assert Cedilla::Citation.new({:title => 'Example', :volume => 'Spring 2013', :article_title => 'Sample article', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a title and volume and article title to be dispatchable!"
    assert Cedilla::Citation.new({:issn => '1234-6789', :volume => 'Spring 2013', :article_title => 'Sample article', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with an identifier and volume and article title to be dispatchable!"
    assert Cedilla::Citation.new({:title => 'Example', :issn => '1234-56789', :volume => 'Spring 2013', :article_title => 'Sample article', :genre => 'article', :content_type => 'full_text'}).dispatchable?, "Expected a citation for a article with a title and an identifier and volume and article title to be dispatchable!"    
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_add_resources
    citation = Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', :issn => 'blah'})
    citation.resources << Cedilla::Resource.new({:source => 'test 1', :target => 'blah blah'})
    citation.resources << Cedilla::Resource.new({:source => 'test 2', :target => 'blah blah blah'})
    
    # The citation should recognize this as a duplicate and NOT add it again!
    dup = Cedilla::Resource.new({:source => 'test 2', :target => 'blah blah blah', :type => 'test', :format => 'print'})
    citation.resources << dup unless citation.has_resource?(dup)
    
    assert_equal 2, citation.resources.count, "Expected there to be 2 resources attached to the citation!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_remove_resources
    citation = Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', :issn => 'blah'})
    citation.resources << Cedilla::Resource.new({:source => 'test 1', :target => 'blah blah'})
    b = Cedilla::Resource.new({:source => 'test 2', :target => 'blah blah blah'})
    citation.resources << b
    
    citation.resources.delete(b)
    
    assert_equal 1, citation.resources.count, "Expected there to be 1 resources attached to the citation!"
    
    # Delete a non-existent resource
    citation.resources.delete(Cedilla::Resource.new({:source => 'foo'}))
    assert_equal 1, citation.resources.count, "Expected there to still be 1 resources attached to the citation after trying to delete a fake resource!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_to_json
    # TODO: Need to rework this test because its dependent on the attributes appearing in a specific order!
    
    citation = Cedilla::Citation.new({:genre => 'foo', :content_type => 'bar', :issn => 'blah', :title => 'Example', :author_last_name => 'Doe', :other => 'what?'})
    citation.resources << Cedilla::Resource.new({:source => 'test 1', :target => 'blah blah'})
    citation.resources << Cedilla::Resource.new({:source => 'test 2', :target => 'blah blah blah'})
    
    json = '{"genre":"foo","content_type":"bar","issn":"blah","title":"Example","author_last_name":"Doe",' +
              '"resources":["{\"source\":\"test 1\",\"target\":\"blah blah\"}","{\"source\":\"test 2\",\"target\":\"blah blah blah\"}"]}'
    
    assert_equal json, citation.to_json, "The JSON received from the Citation object did not match our example!"
  end
  
end