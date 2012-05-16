require 'test/unit'
require Dir.pwd()+'/stativus.rb'
require  Dir.pwd()+'/tests/test_states'
require 'ruby-debug'
class AddState < Test::Unit::TestCase
  def setup
    @statechart = Stativus::Statechart.new

    @statechart.add_state(A)
    @statechart.add_state(B)
    @statechart.add_state(C)

    @statechart.goto_state("B", Stativus::DEFAULT_TREE)
    @statechart.goto_state("C", Stativus::DEFAULT_TREE)
  end #end setup
  
  
  def test_states_were_added
    assert(true, "Sanity check")
    assert_equal(1, @statechart.all_states.keys.length, "should have one tree")
    assert_equal(3, @statechart.all_states[Stativus::DEFAULT_TREE].keys.length, 
                  "should have 3 states in default tree")
    
    
  end


end