class First
  include Stativus::State
  has_concurrent_substates true
  
  def test_event
    self.goto_state('Second')
  end
  
end

class FirstFirst
  include Stativus::State
  parent_state "First"
  initial_substate "FirstFirstFirst"
  
  def test_event
  end
end

class FirstSecond
  include Stativus::State
  parent_state "First"
  inital_substate "FirstSecondFirst"
  
  def test_event
  end
end

class FirstFirstFirst
  include Stativus::State
  parent_state "FirstFirst"
  
  def test_event
    self.goto_state('FirstFirstSecond')
  end
end

class FirstFirstSecond
  include Stativus::State
  parent_state "FirstFirst"
  
  def test_event
  end
end

class FirstSecondSecond
  include Stativus::State
  parent_state 'FirstSecond'
  def test_event
  end
end

class Second
  include Stativus::State
  initial_substate "SecondFirst"
  def test_event
  end
end

class SecondFirst
  include Stativus::State
  parent_state "Second"
  def test_event
  end
end

class SecondSecond
  include Stativus::State
  parent_state "Second"
  
  def test_event
  end
end



