class A < Stativus::State
  has_concurrent_substates true
  def enter
    puts "enered A. I have concurrent substates"
  end
end

class B < Stativus::State
  parent_state "A"
  def enter
    puts "entered B"
  end

  def exit
    puts "exited B"
  end
end

class C < Stativus::State
  parent_state "A"
  def enter
    puts "entered C"
  end

  def exit
    puts "exited C"
  end
end