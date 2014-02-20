require_relative '../test_helper'

class TestResource < Test::Unit::TestCase

  def setup
    
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization

  end

# --------------------------------------------------------------------------------------------------------  
  def test_equality
    # Primary Key is: source + location + target
    a = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'target 1', :location_id => 'Z987 .Y987'})
    b = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'target 1', :location_id => 'A123 .B123'})
    c = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'target 1'})
    
    d = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1'})
    e = Cedilla::Resource.new({:source => 'source 1', :target => 'target 1'})
    f = Cedilla::Resource.new({:location => 'location 1', :target => 'target 1'})
    g = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'target 2'})
    h = Cedilla::Resource.new({:source => 'source 1', :location => 'location 2', :target => 'target 1'})
    i = Cedilla::Resource.new({:source => 'source 2', :location => 'location 1', :target => 'target 1'})
    
    assert a == b, "Resource A should have matched resource B!"
    assert a == c, "Resource A should have matched resource C!"
    assert b == c, "Resource B should have matched resource C!"
    
    assert a != d, "Resource A should NOT have matched resource D"
    assert a != e, "Resource A should NOT have matched resource E"
    assert a != f, "Resource A should NOT have matched resource F"
    assert a != g, "Resource A should NOT have matched resource G"
    assert a != h, "Resource A should NOT have matched resource H"
    assert a != i, "Resource A should NOT have matched resource I"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_to_json
    # TODO: NKeed to rework this test because its dependent on the attributes appearing in a specific order!
    
    resource = Cedilla::Resource.new({:source => 'test 1', :location => 'here', :target => 'blah blah', :location_id => 'A123 .B1234',
                                                  :availability => false, :status => 'reserved', :description => 'blah blah', :type => 'fun stuff',
                                                  :format => 'print', :catalog_target => 'http://ucop.edu'})
    
    json = '{"source":"test 1","location":"here","target":"blah blah","format":"print","type":"fun stuff","description":"blah blah",' +
                '"catalog_target":"http://ucop.edu","availability":false,"status":"reserved"}'
    
    assert_equal json, resource.to_json, "The JSON received from the Resource object did not match our example!"
  end
    
end