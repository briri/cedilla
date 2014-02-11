require_relative '../test_helper'

class TestBroadcaster < Test::Unit::TestCase

  def setup
    @connection = []
    @broadcaster = Cedilla::Broadcaster.new
    @client_id = @broadcaster.register(@connection)
  end

# --------------------------------------------------------------------------------------------------------  
  def test_register
    assert !@client_id.nil?, "The broadcaster did not give us an id!"
    assert @broadcaster.registered?(@client_id), "Expected the id to indicate that the connection is still registered!"
    assert @broadcaster.registered?(@connection), "Expected the connection object to indicate that the connection is still registered!"
  end
  
  def test_broadcast
    i = 0
    # Broadcast a variety of messages and make sure they show up on the client
    ['blah blah', 'yadda yadda', '<some>value</some>', '{"key": "value", "key2": "value"}', ['blurb', 'message']].each do |msg|
      i += 1
      assert @broadcaster.broadcast(@client_id, msg), "Expected a true response when broadcasting #{msg}!"
      assert_equal i, @connection.count, "Expected there to be #{i} messages on the connection after #{msg}! #{@connection.inspect}"
    end
    
    # Test that it fails to broadcast to an unregistered client
    @broadcaster.unregister(@client_id)
    assert !@broadcaster.broadcast(@client_id, 'blah blah blah'), "Expected a false response when broadcasting to an unregistered client!"
  end
  
  def test_unregister
    @broadcaster.unregister(@client_id)
    assert !@broadcaster.registered?(@client_id), "Expected the id to indicate that the connection is NOT still registered!"
    assert !@broadcaster.registered?(@connection), "Expected the connection object to indicate that the connection is NOT still registered!"
  end
  
end