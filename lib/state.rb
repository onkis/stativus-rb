module Stativus
  module State
    attr_accessor :global_concurrent_state, 
                  :local_concurrent_state, 
                  :statechart,
                  :has_concurrent_substates,
                  :parent_state,
                  :initial_substate,
                  :substates,
                  :states,
                  :history
  
    def initialize(statechart)
      @statechart = statechart
      @substates = []
      
      @has_concurrent_substates = self.respond_to?(:_has_concurrent_substates) ? self._has_concurrent_substates : false
      @global_concurrent_state = self.respond_to?(:_global_concurrent_state) ? self._global_concurrent_state : DEFAULT_TREE
      @states = self.respond_to?(:_states) ? self._states : []
      @initial_substate = self.respond_to?(:_initial_substate) ? self._initial_substate : nil
      @parent_state = self.respond_to?(:_parent_state) ? self._parent_state : nil      
    end
  
  
    def goto_state(name)
      sc = @statechart
      if(sc) 
        sc.goto_state(name, @global_concurrent_state, @local_concurrent_state)
      else 
        raise "State has no statechart. Therefore no gotoState"
      end
    end
  
    def goto_history_state(name)
      sc = @statechart
      if(sc) 
        sc.gotoHistroyState(name, @global_concurrent_state, @local_concurrent_state)
      else 
        raise "State has no statechart. Therefore no History State"
      end
    end
  
    def send_event(evt, *args)
      sc = @statechart
      if(sc) 
        sc.send_event(evt, args) 
      else 
        raise "can't send event cause state doesn't have a statechart"
      end
    end
    alias :send_action :send_event

  
    def name
      return self.class.to_s
    end
    
    def to_s
      return self.class.to_s
    end
  
  end #end state module
end #end stativus module