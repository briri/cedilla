require 'json'
require_relative '../test_helper'

class TestBroker < Test::Unit::TestCase

  def setup
    @connection = []
    @broadcaster = Cedilla::Broadcaster.new
    @client_id = @broadcaster.register(@connection)
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_negotiate    
  # missing genre or content_type should return error message
    puts "\n.... Testing invalid citations"
    citation = Cedilla::Citation.new({:content_type => 'full_text', :title => 'Example Journal'})
    broker_proxy(@client_id, citation, @broadcaster)
    assert_equal Cedilla::Aggregator::APP_CONFIG['broker_bad_citation_message'], process_json["error"], "Was expecting the invalid citation error message for a missing genre!"

    citation = Cedilla::Citation.new({:genre => 'journal', :title => 'Example Journal'})
    broker_proxy(@client_id, citation, @broadcaster)
    assert_equal Cedilla::Aggregator::APP_CONFIG['broker_bad_citation_message'], process_json["error"], "Was expecting the invalid citation error message for a missing content type!"
  
  # bogus genre or content_type should return error message
    citation = Cedilla::Citation.new({:genre => 'nonexistent', :content_type => 'full_text', :title => 'Example Journal'})
    broker_proxy(@client_id, citation, @broadcaster)
    assert_equal Cedilla::Aggregator::APP_CONFIG['broker_bad_citation_message'], process_json["error"], "Was expecting the invalid citation error message for a bogus genre!"
  
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'nonexistent', :title => 'Example Journal'})
    broker_proxy(@client_id, citation, @broadcaster)
    assert_equal Cedilla::Aggregator::APP_CONFIG['broker_bad_citation_message'], process_json["error"], "Was expecting the invalid citation error message for a bogus content type!"
    
  # genre => journal, content_type => full_text -- Should return results from both services
    puts ".... Testing genre and content type combo that should get 2 results"
    @connection.clear
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'full_text', :title => 'Example Journal'})
    broker_proxy(@client_id, citation, @broadcaster)
    assert_equal 2, @connection.count, "Expected there to be responses from both of the mock services! #{@connection.inspect}"
    
    json = process_json
    
    assert_equal '1', json['request_id'], "Was expecting the last response from a service to have the value 1 in request_id!"
    assert_equal 'general', json['citation']['subject'], "Was expecting a different subject to have been appended for the genre: journal and content_type: full_text! #{hash}"
    assert !json['citation']['abstract'].nil?, "Was expecting an abstract but none was found for the genre: journal and content_type: full_text!"
    assert_equal 3, json['citation']['resources'].count, "Was expecting 3 resources to have been defined for the genre: journal and content_type: full_text!"
    
  # genre => journal, content_type => purchase -- Should return results from Amazon service ONLY!
    puts ".... Testing genre and content type combo that should get only 1 result"
    @connection.clear
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'purchase', :title => 'Example Journal'})
    broker_proxy(@client_id, citation, @broadcaster)
    assert_equal 1, @connection.count, "Expected there to be only one response from the mock services! #{@connection.inspect}"
    
    json = process_json
    assert json['citation']['subject'].nil?, "Was expecting there to be no subject because only the Amazon service should have been called for genre: journal and content_type: purchase!"
    assert !json['citation']['abstract'].nil?, "Was expecting an abstract but none was found for the genre: journal and content_type: purchase!"
    assert_equal 1, json['citation']['resources'].count, "Was expecting 1 resource to have been defined for the genre: journal and content_type: purchase!"
    
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def test_augment_citation
    broker = Cedilla::Broker.new
    params = {:genre => 'journal', :content_type => 'full_text', :title => 'Example Journal'}
    original = Cedilla::Citation.new(params)
    
    params[:volume] = 'Spring 2013'; params[:abstract] = 'Some info about the journal.'; params[:foo] = 'bar'
    original = broker.augment_citation(original, Cedilla::Citation.new(params))
    
    assert_equal 'Spring 2013', original.volume, "Was expecting the citation to now contain a volume!"
    assert !original.abstract.nil?, "Was expecting the citation to now contain an abstract!"
    
    # Test attribute override
    params[:subject] = 'General'; params[:volume] = 'May 2013'
    original = broker.augment_citation(original, Cedilla::Citation.new(params))
    
    assert_equal 'General', original.subject, "Was expecting the citation to now contain a subject!"
    assert_equal 'May 2013', original.volume, "Was expecting the citation's volume to have changed!"
    
    # Test Resource assignments
    params[:resources] = [Cedilla::Resource.new({:source => 'Some website', :location => nil, :target => 'http://www.ucop.edu', :format => 'electronic'})]
    original = broker.augment_citation(original, Cedilla::Citation.new(params))
    
    assert_equal 1, original.resources.count, "Was expecting the citation to now have 1 resource!"
    
    params[:resources] = [Cedilla::Resource.new({:source => 'Some website', :location => nil, :target => 'http://www.ucop.edu', :format => 'electronic'}),
                          Cedilla::Resource.new({:source => 'The all knowing Google', :target => 'http://www.ucop.edu/google/1', :format => 'electronic'})]
    original = broker.augment_citation(original, Cedilla::Citation.new(params))
    
    assert_equal 2, original.resources.count, "Was expecting the citation to now have 2 resources (one of the resoources should have already existsed)!"

    # Test Others paramaters
    params[:blah] = 'blah blah'; params[:yadda] = 'yadda yadda'; params[:foo] = 'bar'
    original = broker.augment_citation(original, Cedilla::Citation.new(params))
    
    assert_equal 3, original.others.count, "Was expecting the citation to contain 3 other params (one of the other params was a duplicate and should have been skipped)!"
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def process_json
    # Extract the data section from the result
    data = @connection.last[/data:\s+{.*}/].gsub('data: ', '')
    
    JSON.parse(data)
  end
  
end


# --------------------------------------------------------------------------------------------------------------------
# Mock services for testing core component logic
# --------------------------------------------------------------------------------------------------------------------
class AmazonService < Cedilla::Service
    def submit(citation)
      sleep(8)  # sleep to ensure that the broker is handling async calls and that it shuts down when its supposed to!
      
      citation.author_full_name = 'Doe, John'
      citation.abstract = 'This is an example abstract returned from our test service to augment the citation.'
      
      citation.resources << Cedilla::Resource.new({:source => 'Some website', :location => nil, :target => 'http://www.ucop.edu', :format => 'electronic'})
      
      citation
    end
end

class GoogleBooksService < Cedilla::Service
    def submit(citation)
      citation.subject = 'general'
      
      citation.resources << Cedilla::Resource.new({:source => 'The all knowing Google', :target => 'http://www.ucop.edu/google/1', :format => 'electronic'})
      citation.resources << Cedilla::Resource.new({:source => 'The all knowing Google', :target => 'http://www.ucop.edu/google/2', :format => 'electronic'})
      
      citation
    end
end