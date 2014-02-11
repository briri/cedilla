require_relative '../test_helper'
require 'json'

class TestTranslator < Test::Unit::TestCase

  def setup
    # Default test openurl translation. This also contains a non-openurl paramter to make sure the 'others' attribute of
    # citation comes across as-is
    @openurl = "rft.genre=article&rft.title=journal%20of%20something&rft.issn=1234-1234&rft.volume=17&rft.issue=1" +
              "&rft.atitle=Article%20title&my_param=A%20New%20value" 
    @openurl_citation = Cedilla::Translator.query_string_to_citation("openurl", @openurl)
    
    @json = nil
  end

# --------------------------------------------------------------------------------------------------------------------
  def test_query_string_to_citation
    # Test that no translation file and no query string returns an empty citation
    citation = Cedilla::Translator.query_string_to_citation("nothing", nil)
    assert citation.identifiers['issn'].nil?, "Should have returned an empty citation when the query string was empty and no translation file was provided!"
      
    # Test that no translation file tries to match values directly from the citation object's property names
    citation = Cedilla::Translator.query_string_to_citation("nothing", "#{@openurl}&issn=0000-0001")    
    assert citation.title.nil?, "A title should not have been loaded for the default translation!"
    assert !citation.others.nil?, "Should have collected undefined params for the default translation!"
    
    # Test to make sure the translation file is properly loading the citation object
    citation = Cedilla::Translator.query_string_to_citation("openurl", "#{@openurl}&issn=0000-0001")
    assert_equal "1234-1234", citation.identifiers['issn'], "Should have returned the ISSN for 'rft.issn' instead of 'issn' because a translation file WAS provided!"
    assert !citation.article_title.nil?, "An article title should have been loaded for the openurl translation format!"
    assert !citation.genre.nil?, "The genre was not loaded for the openurl translation format!"
    assert !citation.title.nil?, "The title was not loaded for the openurl translation format!"
    assert !citation.volume.nil?, "The volume was not loaded for the openurl translation format!"
    assert !citation.issue.nil?, "The issue was not loaded for the openurl translation format!"
    assert !citation.others.nil?, "Should have collected undefined params for the openurl translation format!"

    # Make sure the process decoded the values
    assert !citation.title.include?('%20'), "The translation process did not decode the URL values! Title: #{citation.title}"
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_citation_to_query_string
    # Make sure that it returns nil when no citation is provided
    assert !Cedilla::Translator.citation_to_query_string("nothing", nil)
    
    # Test that the function returns the default query string when no translation file is presented
    out = Cedilla::Translator.citation_to_query_string("nothing", @openurl_citation)
    assert out.include?("genre=article"), "The query string did not include the genre!" 
    assert out.include?("title=journal%20of%20something"), "The query string did not include the title!" 
    assert out.include?("issn=1234-1234"), "The query string did not include the issn!" 
    assert out.include?("volume=17"), "The query string did not include the volume!" 
    assert out.include?("issue=1"), "The query string did not include the issue!" 
    assert out.include?("article_title=Article%20title"), "The query string did not include the article title!" 
    assert out.include?("my_param=A%20New%20value"), "The query string should contain the undefined params! #{out}"
    
    # Test that the function returns the original openurl query string when passed translation file for openurl
    out = Cedilla::Translator.citation_to_query_string("openurl", @openurl_citation)
    assert_equal "article", @openurl_citation.genre
    assert out.include?("rft.genre=article"), "The query string did not include the rft.genre for openurl!" 
    assert out.include?("rft.title=journal%20of%20something"), "The query string did not include the rft.title for openurl!" 
    assert out.include?("rft.issn=1234-1234"), "The query string did not include the rft.issn for openurl!" 
    assert out.include?("rft.volume=17"), "The query string did not include the rft.volume for openurl!" 
    assert out.include?("rft.issue=1"), "The query string did not include the rft.issue for openurl!" 
    assert out.include?("rft.atitle=Article%20title"), "The query string did not include the rft.atitle for openurl!"
    assert out.include?("my_param=A%20New%20value"), "The query string should contain the undefined params!"
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_json_to_citation

  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_json_to_resources

  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_citation_to_json

  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_resources_to_json

  end
  
end
  