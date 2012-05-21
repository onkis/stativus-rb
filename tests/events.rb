require 'test/unit'
require Dir.pwd()+'/stativus.rb'
require 'ruby-debug'

$state_transitions = []

module AllEnterExit
  def enter
    $state_transitions.push "ENT: "+self.name
  end
  
  def exit
    $state_transitions.push "EXT: "+self.name
  end
  
  def test_event(*args)
    $state_transitions.push("EVT: "+self.name+".test_event")
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
    
    @statechart.send_event('test_event')
    assert_equal(4, $state_transitions.length(), "4 transitions after first event")
    @statechart.send_event('test_event')
    assert_equal(9, $state_transitions.length(), "9 transitions after first event")
  end
end