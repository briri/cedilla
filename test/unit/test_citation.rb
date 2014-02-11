require_relative '../test_helper'

class TestCitation < Test::Unit::TestCase

  def setup
    
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    citation = get_citation({})
    assert citation.resources.empty?, "Was expecting the citations resources to be initialized to an empty array!"
    assert citation.others.empty?, "Was expecting the citations others property to be initialized to an empty hash!"
  end

# --------------------------------------------------------------------------------------------------------    
  def test_valid
    # No genre or content type - should fail
    assert !get_citation({}).valid?, "An empty citation should not pass the validation check!"
    
    # No genre - should fail
    assert !get_citation({:content_type => 'bar'}).valid?, "A citation with no genre should not pass the validation check!"
    
    # No content type - should fail
    assert !get_citation({:genre => 'foo'}).valid?, "A citation with no content type should not pass the validation check!"
    
    # genre and content type but no identifier or title - should fail
    assert !get_citation({:genre => 'foo', :content_type => 'bar'}).valid?, "A citation with no title or identifier should not pass the validation check!"
    
    # genre, content type, and identifier - should pass
    Cedilla::Citation.new.identifiers.each do |key,val|
      assert get_citation({:genre => 'foo', :content_type => 'bar', key => 'blah'}).valid?, "A citation with a genre, content type, and an #{key} should pass the validation check!"
    end
    
    # genre, content type, and title - should pass
    assert get_citation({:genre => 'foo', :content_type => 'bar', :title => 'blah'}).valid?, "A citation with a genre, content type, and a title should pass the validation check!"
    assert get_citation({:genre => 'foo', :content_type => 'bar', :article_title => 'blah'}).valid?, "A citation with a genre, content type, and a article title should pass the validation check!"
    assert get_citation({:genre => 'foo', :content_type => 'bar', :journal_title => 'blah'}).valid?, "A citation with a genre, content type, and a journal title should pass the validation check!"
    assert get_citation({:genre => 'foo', :content_type => 'bar', :book_title => 'blah'}).valid?, "A citation with a genre, content type, and a book title should pass the validation check!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_has_identifier
    # Test that it returns false when it has no identifiers
    assert !get_citation({}).has_identifier?, "Expected there to be no identifiers for an empty citation!"
    assert !get_citation({:genre => 'foo', :content_type => 'bar'}).has_identifier?, "Expected there to be no identifiers with just genre and content type defined!"
    assert !get_citation({:genre => 'foo', :content_type => 'bar', :title => 'blah'}).has_identifier?, "Expected there to be no identifiers with just genre and content type defined!"
    
    # Test the various identifiers to make sure they each work
    Cedilla::Citation.new.identifiers.each do |key,val|
      assert get_citation({:genre => 'foo', :content_type => 'bar', key => 'blah'}).has_identifier?, "Expected citation to confirm an identifier exists when an #{key} is defined!"
    end
    
    # Test that it returns true when it has multiple identifiers
    assert get_citation({:genre => 'foo', :content_type => 'bar', :issn => 'blah', :isbn => 'yadda'}).has_identifier?, "Expected citation to confirm an identifier exists when multiple identifiers are defined!"
  end
   
# --------------------------------------------------------------------------------------------------------  
  def test_get_identifiers
    # Test to make sure that the identifiers are empty when they should be
    assert !get_citation({}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers for an empty citation!"
    assert !get_citation({:genre => 'foo', :content_type => 'bar'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    assert !get_citation({:genre => 'foo', :content_type => 'bar', :title => 'blah'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    
    # Test the various identifiers to make sure they each work
    Cedilla::Citation.new.identifiers.each do |key,val|
      assert_equal 'blah', get_citation({:genre => 'foo', :content_type => 'bar', key => 'blah'}).identifiers[key], "Expected citation to confirm an identifier exists when an #{key} is defined!"
    end
    
    # Test that it returns true when it has multiple identifiers
    citation = get_citation({:genre => 'foo', :content_type => 'bar', :issn => 'blah', :isbn => 'yadda'})
    assert_equal 'blah', citation.identifiers['issn'], "Expected citation to confirm an issn identifier when both the issn and isbn identifiers were defined!"
    assert_equal 'yadda', citation.identifiers['isbn'], "Expected citation to confirm an isbn identifier when both the issn and isbn identifiers were defined!"
  end 
  
# --------------------------------------------------------------------------------------------------------  
  def test_add_resources
    citation = get_citation({:genre => 'foo', :content_type => 'bar', :issn => 'blah'})
    citation.resources << Cedilla::Resource.new
    citation.resources << Cedilla::Resource.new
    
    assert_equal 2, citation.resources.count, "Expected there to be 2 resources attached to the citation!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_remove_resources
    citation = get_citation({:genre => 'foo', :content_type => 'bar', :issn => 'blah'})
    citation.resources << Cedilla::Resource.new
    b = Cedilla::Resource.new
    citation.resources << b
    
    citation.resources.delete(b)
    
    assert_equal 1, citation.resources.count, "Expected there to be 1 resources attached to the citation!"
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def get_citation(params)
    citation = Cedilla::Citation.new
    params.each{ |key,val| citation.method("#{key}=").call(val) if citation.respond_to?("#{key}=") }
    citation
  end
  
end