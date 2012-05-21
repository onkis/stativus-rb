class First < Stativus::State
  has_concurrent_substates true
  
  def test_event
    self.goto_state('Second')
  end
  
end

class FirstFirst < Stativus::State
  parent_state "First"
  initial_substate "FirstFirstFirst"
  
  def test_event
  end
end

class FirstSecond < Stativus::State
  parent_state "First"
  inital_substate "FirstSecondFirst"
  
  def test_event
  end
end

class FirstFirstFirst < Stativus::State
  parent_state "FirstFirst"
  
  def test_event
    self.goto_state('FirstFirstSecond')
  end
end

class FirstFirstSecond < Stativus::State
  parent_state "FirstFirst"
  
  def test_event
  end
end

class FirstSecondSecond < Stativus::State
  parent_state 'FirstSecond'
  def test_event
  end
end

class Second < Stativus::State
  initial_substate "SecondFirst"
  def test_event
  end
end

class SecondFirst < Stativus::State
  parent_state "Second"
  def test_event
  end
end

class SecondSecond < Stativus::State
  parent_state "Second"
  
  def test_event
  end
end



