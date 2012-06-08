class Object
  #
  # My ruby foo is weak and i really with there was another way to setup
  # data on a class other than calling send :define_method then checking
  # for the existence of this method...
  def self.has_concurrent_substates(value)
    send :define_method, :_has_concurrent_substates do
      return value
    end
  end
  
  def self.global_concurrent_state(state)
    send :define_method, :_global_concurrent_state do
      return state
    end
  end
  
  def self.states(*states)
    send :define_method, :_states do
      return states
    end
  end
  
  def self.initial_substate(state)
    send :define_method, :_initial_substate do
      return state
    end
  end
  
  def self.parent_state(state)
    send :define_method, :_parent_state do
      return state
    end
  end
end