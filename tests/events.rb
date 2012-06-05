require 'test/unit'


$state_transitions = []

module AllEnterExit
  def enter
    #puts "ENT: "+self.name
    $state_transitions.push "ENT: "+self.name
  end
  
  def exit
    #puts "EXT: "+self.name
    $state_transitions.push "EXT: "+self.name
  end
  
  def test_event
    $state_transitions.push("EVT: "+self.name+".test_event")
    return false
  end
  
end


class Application < Stativus::State
  include AllEnterExit
  initial_substate "SubApplication"
end

class SubApplication < Stativus::State
  include AllEnterExit
  parent_state "Application"
  has_concurrent_substates true
end

class First < Stativus::State
  include AllEnterExit
  parent_state "SubApplication"
  initial_substate "FirstFirst"
end

class FirstFirst < Stativus::State
  include AllEnterExit
  parent_state "First"
  
  def test_event(*args)
    $state_transitions.push('EVT: '+self.name+'.test_event')
    self.goto_state("FirstSecond")
    return true
  end
end

class FirstSecond < Stativus::State
  include AllEnterExit
  parent_state "First"
end

class Second < Stativus::State
  include AllEnterExit
  parent_state "SubApplication"
end




class Events < Test::Unit::TestCase
  def setup
    @statechart = Stativus::Statechart.new

    @statechart.add_state(Application)
    @statechart.add_state(SubApplication)
    @statechart.add_state(First)
    @statechart.add_state(FirstFirst)
    @statechart.add_state(FirstSecond)
    @statechart.add_state(Second)
        
    @statechart.start("Application")
    
    #state_transitions = []

  end #end setup
  
  def test_event_propagation
    expected_events = ['EVT','EVT', 'EXT', 'ENT', 'EVT', 'EVT', 'EVT', 'EVT', 'EVT']
    $state_transitions = []
    @statechart.send_event('test_event')
    #puts $state_transitions
    assert_equal(4, $state_transitions.length(), "4 transitions after first event")
    @statechart.send_event('test_event')
    #puts "second time"
    #puts $state_transitions
    assert_equal(9, $state_transitions.length(), "9 transitions after second event")
  end
end