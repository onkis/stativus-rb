require 'test/unit'
require Dir.pwd()+'/stativus.rb'
require  Dir.pwd()+'/tests/test_states'

class AddState < Test::Unit::TestCase
  def setup
    @statechart = Stativus::Statechart.new

    @statechart.add_state(A)
    @statechart.add_state(B)
    @statechart.add_state(C)

    @statechart.goto_state("B", "default")
    @statechart.goto_state("C", "default")
  end #end setup
  
  
  def test_states_were_added
    asset(true, "did work")
    
  end


end