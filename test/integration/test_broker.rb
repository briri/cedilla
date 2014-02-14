require_relative '../test_helper'

class TestBroker < Test::Unit::TestCase

  def setup
    @connection = []
    @broadcaster = Cedilla::Broadcaster.new
    @client_id = @broadcaster.register(@connection)
  end

# --------------------------------------------------------------------------------------------------------  
  def test_negotiate
    broker = Cedilla::Broker.new
    
    citation = get_citation({:genre => 'journal', :content_type => 'full_text', :title => 'Example Journal'})

    broker.negotiate(@client_id, citation, @broadcaster)
    
    assert_equal 2, @connection.count, "Expected there to be responses from both of the mock services! #{@connection.inspect}"
    
    @connection.each do |message|
      puts message
    end
  end
  
# --------------------------------------------------------------------------------------------------------------------
  def get_citation(params)
    Cedilla::Citation.new(params)
    #params.each{ |key,val| citation.method("#{key}=").call(val) if citation.respond_to?("#{key}=") }
    #citation
  end
  
end


# --------------------------------------------------------------------------------------------------------------------
# Mock services for testing core component logic
# --------------------------------------------------------------------------------------------------------------------
class AmazonService < Cedilla::Service
    def submit(citation)
      sleep(8)  # sleep to ensure that the broker is handling async calls and that it shuts down when its supposed to!
      
      citation
    end
end