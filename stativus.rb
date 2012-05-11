module Stativus
  class State
    attr_accessor :global_concurrent_state, 
                  :local_concurrent_state, 
                  :statechart,
                  :has_concurrent_substates,
                  :parent_state,
                  :substates,
                  :states,
                  :history
  
    def initialize(statechart)
      @statechart = statechart
      @substates = []
      @has_concurrent_substates = false unless @has_conurrent_substates
      @global_concurrent_state = DEFAULT_TREE unless @global_concurrent_state
      puts @global_concurrent_state
    end
  
  
    def gotoState(name)
      sc = @statechart
      if(sc) 
        sc.gotoState(name, @global_concurrent_state, @local_concurrent_state)
      else 
        raise "State has no statechart. Therefore no gotoState"
      end
    end
  
    def gotoHistoryState(name)
      sc = @statechart
      if(sc) 
        sc.gotoHistroyState(name, @global_concurrent_state, @local_concurrent_state)
      else 
        raise "State has no statechart. Therefore no History State"
      end
    end
  
    def sendEvent(evt, *args)
      sc = @statechart
      if(sc) 
        sc.sendEvent(evt, args) 
      else 
        raise "can't send event cause state doesn't have a statechart"
      end
    end
    alias :sendAction :sendEvent
    #
    #
    #data methods, override these in your implementations
    #

    def self.has_concurrent_substates(b)
      @has_concurrent_substates = b
    end
  
    def self.global_concurrent_state(state)
      @global_concurrent_state = state 
    end
  
    def self.parent_state(state)
      @parent_state = state
    end
  
    def self.states(*states)
      @staes = states
    end
  
    def name
      return self.class.to_s
    end
  
  end

  DEFAULT_TREE = "default"

  class Statechart
    attr_accessor :all_states,
                  :states_with_concurrent_substates,
                  :current_subtrees,
                  :current_state,
                  :gotoStateLocked,
                  :send_event_locked,
                  :pending_state_transitions,
                  :pending_events,
                  :active_subtrees
  
    def initialize()
      @all_states = {}
      @all_states[DEFAULT_TREE] = {}
      @states_with_concurrent_substates = {}
      @current_subsates = {}
      @current_state = {}
      @current_state[DEFAULT_TREE] = {}
      @gotoStateLocked = false
      @send_event_locked = false
      @pending_state_transitions = []
      @pending_events = []
      @active_subtrees = {}
    end
  
    def add_state(state_class)
      state = state_class.new(self)
      puts state.global_concurrent_state
      tree = state.global_concurrent_state
      parent_state = state.parent_state
      current_tree = @states_with_concurrent_substates[tree]
    
      if(state.has_concurrent_substates)
        obj = @states_with_concurrent_substates[tree] || {}
        obj[state.name] = true
        @states_with_concurrent_substates[tree] = obj
      end
    
      if(parent_state and current_tree and current_tree[parent_state])
        parent_state = @all_states[tree][parent_state]
        if(parent_state)
          parent_state.substates.push(state.name)
        end
      end
    
      obj = @all_states[tree] || {}
    
      obj[state.name] = state
    
      states = state
    puts @all_states
    end
  
  end
end
