require_relative '../test_helper'

class TestRules < Test::Unit::TestCase

  def setup
    @rules = Cedilla::Rules.new
  end

# --------------------------------------------------------------------------------------------------------  
  def test_configuration_loaded
    assert !@rules.genres.empty?, 'The default list of valid genres was not loaded from the configuration file!'
    assert !@rules.content_types.empty?, 'The default list of valid content types was not loaded from the configuration file!'
    assert !@rules.minimum_citation_groups.empty?, 'The default list of valid minimum citation groups was not loaded from the configuration file!'
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_get_available_services
    # Test NO matches due to undefined genre and undefined content_type
    citation = get_citation({:genre => 'bar', :content_type => 'foo'})
    assert @rules.get_available_services(citation).empty?, "Was expecting 0 services for foo and bar!" 
    
    # Test NO matches due to undefined genre
    citation = get_citation({:genre => 'bar', :content_type => 'full_text'})
    assert @rules.get_available_services(citation).empty?, "Was expecting 0 services for full_text and bar!" 
    
    # Test NO matches due to undefined content_type
    citation = get_citation({:genre => 'journal', :content_type => 'foo'})
    assert @rules.get_available_services(citation).empty?, "Was expecting 0 services for foo and journal!" 
    
    # Test 1 match based on content_type limitation
    citation = get_citation({:genre => 'book', :content_type => 'purchase'})
    assert_equal 1, @rules.get_available_services(citation).count, "Was expecting 1 service for purchase and book!" 
    
    # Test 1 match based on genre limitation
    citation = get_citation({:genre => 'article', :content_type => 'full_text'})
    out = @rules.get_available_services(citation)
    assert_equal 1, out.count, "Was expecting 1 for service full_text and article! #{out}" 
    assert out.include?('google_books'), "Was expecting the service to have returned 'google_books' for service full_text and article! #{out}"
    
    # Test 2 matches
    citation = get_citation({:genre => 'book', :content_type => 'full_text'})
    out = @rules.get_available_services(citation)
    assert_equal 2, out.count, "Was expecting 2 services for full_text and book!" 
    assert (out.include?('amazon') and out.include?('google_books')), "Was expecting the service to have returned both 'amazon' and 'google_books' for full_text and book!"
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_translate_genre
    assert @rules.translate_genre('blah').nil?, "Was expecting the translation of 'blah' to fail because it is undefined!"
    assert_equal 'dissertation', @rules.translate_genre('theses'), "Was expecting to get 'dissertation' when translating genre 'theses'!"
  end
   
# --------------------------------------------------------------------------------------------------------------------
  def test_can_dispatch_to_service
    # Try both an invalid genre and content_type
    citation = get_citation({:genre => 'foo', :content_type => 'bar', :title => 'Pride and Prejudice'})
    assert !@rules.can_dispatch_to_service?('google_books', citation), 'Should not have been able to dispatch a citation with genre: foo and content_type: bar!'
    
    # Try an invalid genre
    citation = get_citation({:genre => 'foo', :content_type => 'full_text', :title => 'Pride and Prejudice'})
    assert !@rules.can_dispatch_to_service?('google_books', citation), 'Should not have been able to dispatch a citation with genre: foo and content_type: full_text!'
    
    # Try an invalid content_type
    citation = get_citation({:genre => 'journal', :content_type => 'bar', :title => 'Pride and Prejudice'})
    assert !@rules.can_dispatch_to_service?('google_books', citation), 'Should not have been able to dispatch a citation with genre: journal and content_type: bar!'
    
    # Try a valid citation with valid genre and content type but no matching service
    citation = get_citation({:genre => 'article', :content_type => 'purchase', :title => 'Pride and Prejudice'})
    assert !@rules.can_dispatch_to_service?('google_books', citation), 'Should not have been able to dispatch a citation with genre: foo and content_type: bar!'
    
    # Try a valid citation with valid genre and content type AND a matching service
    citation = get_citation({:genre => 'book', :content_type => 'full_text', :title => 'Pride and Prejudice'})
    assert @rules.can_dispatch_to_service?('google_books', citation), 'Should not have been able to dispatch a citation with genre: foo and content_type: bar!'
  end 
  
# --------------------------------------------------------------------------------------------------------------------
  def test_has_minimum_citation_requirements
    # Test missing genre type - should fail
    citation = get_citation({:content_type => 'bar', :title => 'Pride and Prejudice'})
    assert !@rules.has_minimum_citation_requirements?(citation), "Was expecting the test to fail because no genre was defined!"
    
    # Test missing content type - should fail
    citation = get_citation({:genre => 'foo', :title => 'Pride and Prejudice'})
    assert !@rules.has_minimum_citation_requirements?(citation), "Was expecting the test to fail because content_type was defined!"
    
    # Test book genre with no title
    citation = get_citation({:genre => 'book', :content_type => 'full_text', :author_last_name => 'Dickens'})
    assert !@rules.has_minimum_citation_requirements?(citation), "Was expecting the test to fail because no title was supplied for a book genre!"
    
    # Test book genre with a title by multiple property OR logic
    citation = get_citation({:genre => 'book', :content_type => 'full_text', :author_last_name => 'Dickens', :title => 'A Tale of Two Cities'})
    assert @rules.has_minimum_citation_requirements?(citation), "Was expecting the test to pass because a title was supplied for a book genre!"
    
    # Test book genre with a title by single property AND logic with a failure in the multi-property OR logic
    citation = get_citation({:genre => 'article', :content_type => 'full_text', :author_last_name => 'Dickens', :article_title => 'Wasting time'})
    assert !@rules.has_minimum_citation_requirements?(citation), "Was expecting the test to fail because an article title was supplied but no journal title was provided for the article genre!"
    
    # Test book genre with a title by single property AND logic and multi-property OR logic
    citation = get_citation({:genre => 'article', :content_type => 'full_text', :author_last_name => 'Dickens', :article_title => 'Wasting time', :journal_title => 'Some obscure title'})
    assert @rules.has_minimum_citation_requirements?(citation), "Was expecting the test to pass because an article title and a journal title were supplied for the article genre!"
    
    # Test article genre with issn number
    citation = get_citation({:genre => 'article', :content_type => 'full_text', :article_title => 'My article title', :issn => '1234-1234-1234'})
    assert @rules.has_minimum_citation_requirements?(citation), "Was expecting the test to pass because it has an identifier, genre, and content type!"
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def get_citation(params)
    Cedilla::Citation.new(params)
    #params.each{ |key,val| citation.method("#{key}=").call(val) if citation.respond_to?("#{key}=") }
    #citation
  end
  
end