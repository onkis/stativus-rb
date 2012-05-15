module Stativus
  class State
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
      @has_concurrent_substates = false unless @has_conurrent_substates
      @global_concurrent_state = DEFAULT_TREE unless @global_concurrent_state
      puts @global_concurrent_state
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
    
    def self.initial_substate(state)
      @initial_substate = name
    end
  
    def name
      return self.class.to_s
    end
  
  end

  DEFAULT_TREE = "default"
  SUBSTATE_DELIM = "SUBSTATE:"
  class Statechart
    attr_accessor :all_states,
                  :states_with_concurrent_substates,
                  :current_subtrees,
                  :current_state,
                  :goto_state_locked,
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
      @goto_state = false
      @send_event_locked = false
      @pending_state_transitions = []
      @pending_events = []
      @active_subtrees = {}
      @goto_state_locked = false
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
    
      sub_states = state.states
      
      sub_states.each do |sub_state|
        sub_state.parent_state = state
        sub_state.global_concurrent_state = tree
        add_state(sub_state)
      end
      
      puts @all_states
    end #add_state
  
    # call this in your programs main
    # state is the initial state of the application
    # in the default tree
    def start_statechart(state)
      self.goto_state(init, DEFAULT_TREE)
    end
  
    def goto_state(requested_state_name, tree, concurrent_tree)
      all_states = @all_states[tree]
      
      #First, find the current tree off of the concurrentTree, then the main tree
      curr_state = concurrent_tree ? @current_state[concurrent_tree] : @current_state[tree]
      
      requested_state = all_states[requested_state_name]
      # if the current state is the same as the requested state do nothing
      return if(check_all_current_states(requested_state, concurrent_tree || tree))
      
      
      if(@goto_state_locked)
        #There is a state transition currently happening. Add this requested
        #state transition to the queue of pending state transitions. The req
        #will be invoked after the current state transition is finished
        @pending_state_transitions.push({
          :requested_state => requested_state_name,
          :tree => tree
        })
        return
      end
      # Lock for the current state transition, so that it all gets sorted out
      # in the right order
      @goto_state_locked = true
      
      # Get the parent states for the current state and the registered state.
      # we will use them to find the commen parent state
      enter_states = parent_states_with_root(requested_state)
      exit_states = curr_state ? parent_states_with_root(curr_state) : []
      #
      # continue by finding the common parent state for the current and 
      # requested states:
      #
      # At most, this takes O(m^2) time, where m is the maximum depth from the 
      # root of the tree to either the requested state or the current state.
      # Will always be less than or equal to O(n^2), where n is the number
      # of states in the tree
      enter_match_index = -1
      exit_state.each_index do |idx|
        exit_match_index = idx
        enter_match_index = enter_states.index(exit_state[idx])
        break if(enter_match_index != nil)    
      end
      
      # In the case where we don't find a common parent state, we 
      # must enter from the root state
      enter_match_state = enter_states.length -1 if(enter_match_index == nil)
      
      #setup the enter state sequence
      @enter_states = enterstates
      @enter_state_match_index = enter_match_index
      @enter_state_concurrent_tree = concurrent_tree
      @enter_state_tree = tree
      
      # Now, we will exit all the underlying states till we reach the common
      # parent state. We do not exit the parent state because we transition
      # within it.
      @exit_state_stack = []
      full_exit_from_substates(tree, curr_state) if(curr_state and curr_state.substates_are_concurrent)
      for i = 0; i < exit_match_index; i++ 
        curr_state = exit_states[i]
        @exit_state_stack.push(curr_state)
      end
      
      #Now that we have the full stack of states to exit
      #we can exit them...
      unwind_exit_state_stack();
      
      
    end #end goto_state
    
    #
    # Private functions
    #
    private
    
    # this function exits all items next on the exit state stack
    def unwind_exit_state_stack
      @exit_state_stack = @exit_state_stack || []
      state_to_exit = @exit_state_stack.shift
      
      if state_to_exit
        if(state_to_exit.will_exit_state)
          
          state_restart = {
            :statechart => self,
            :start => state_to_exit
          }
          #todo : i'm pretty sure this won't work as written...
          state_restart[:restart] = Proc.new {
            #if(debugMode) puts ['RESTART: after async processing on,', self[:start].name, 'is about to fully exit'].join(' ')
            @statechart.full_exit(state_restart[:start])
          }
          delay_for_async = state_to_exit.will_exit_state(state_restart)
          
          full_exit(state_to_exit) unless delay_for_async
        end
      else
        @exit_state_stack = nil
        initiate_enter_state_sequence
      end
    end
    
    def full_exit(state)
      return unless state
      exit_state_handled = false
      state.exit if(state.respond_to?(:exit))
      state.did_exit_state if(state.respond_to(:did_exit_state))
      #todo: if (DEBUG_MODE) console.log('EXIT: '+state.name);
      unwind_exit_state_stack
    
    def full_exit_from_substates(tree, stop_state)
      
      return if(!tree || !stop_state)
      
      all_states = @all_states[tree]
      curr_states = @current_state
      @exit_state_stack = @exit_state_stack || []
      
      stop_state.substates.each do |state|
        substate_tree = [SUBSTATE_DELIM, tree, stop_state.name, state].join("=>")
        curr_state = curr_states[substate_tree]
        
        while(curr_state and curr_state !== stop_state)
          exit_state_handled = false
          @exit_state_stack.unshift(curr_state)
          
          #check to see if it has substates
          full_exit_from_substates(tree, curr_state) if(curr_state.has_concurrent_substates)
          
          #up to the next parent
          curr = curr_state.parent_state
          curr_state = all_states[curr]
        end
        
      end
      
    end
    
    def initiate_enter_state_sequence
      enter_states = @enter_states
      enter_match_index = @enter_state_match_index
      concurrent_tree = @enter_state_concurrent_tree
      tree = @enter_state_tree
      all_states = @all_states[tree]
      
      #initalize the enter state stack
      @enter_state_stack = @enter_state_stack || []
      
      # Finally, from the common parent state, but not including the parent state,
      # enter the sub states down to the requested state. If the requested state
      # has an initial sub state, then we must enter it too
      i = enter_match_index - 1
      curr_state = enter_states[i]
      if(curr_state)
        cascade_enter_substates(curr_state, enter_states, 
                                (i-1), concurrent_tree || tree, all_states)
      end
      
      #once, we have fully hydrated the Enter State Stack, we must actually async unwind it 
      unwind_enter_state_stack
      
      #cleanup
      @enter_states = @enter_state_match_index = @enter_state_concurrent_tree = 
      @enter_state_tree = nil
      
    end
    
    def cascade_enter_substates(start, required_states, index, tree, all_states)
      return unless start
      
      name = start.name
      @enter_state_stack.push(start)
      @current_state[tree] = start
      start.local_concurrent_state = tree
      
      if(start.has_concurrent_substates)
        tree = start.glboal_concurrent_state || DEFAULT_TREE
        next_tree = [SUBSTATE_DELIM,tree,name].join("=>")
        start.history = start.history || {}
        subsates = start.substates || []
        substates.each do |x|
          next_tree = tree +"=>"+x
          curr_state = all_states[x]
          
          # Now, we have to push the item onto the active subtrees for
          # the base tree for later use of the events.
          b_tree = curr_state.glboal_concurrent_state || DEFAULT_TREE
          a_trees = active_subtrees[bTree] || []
          a_trees.unshift(next_tree)
          @active_subtrees[b_tree] = a_trees
          index -=1 if(index > -1 && required_states[index] == curr_state)
          cascade_enter_substates(curr_state, required_states, index, next_tree, all_states)
        end
        return
      else
        curr_state = required_states[index]
        if(curr_state)
          parent_state = all_states[curr_state.parent_state]
          if(parent_state)
            if(parent_state.has_concurrent_substates)
              parent_state.history[tree] = curr_state.name
            else
              parent_state.history = current_state.name
            end
          end #end parent state
          
          index -=1 if(index > -1 && required_states[index] == curr_state)
          cascade_enter_substates(curr_state, required_states, index, next_tree, all_states)
        else
          curr_state = all_states[start.initial_substate]
          cascade_enter_substates(curr_state, required_states, index, next_tree, all_states)
        end
      end
  
    end
        
    def unwind_enter_state_stack
      @exit_state_stack = @exit_state_stack || []
      state_to_enter = @enter_state_stack.shift()
      
      if state_to_enter
        if 
      
    end
    def check_all_current_states(requested_state, tree)
      current_states = @current_state[tree] || []
      
      if(current_states == requested_state)
        return true
      elsif(current_states.class == String and requested_state == @all_states[tree][current_states])
        return true
      elsif(current_states.class == Array and currnet_states.contains(requested_state))
        return true
      else
        return false
      end
    end
    
    # returns the state object for a passed name and tree
    # was called _parentStateObject in js
    def state_object(name, tree)
      if(name && tree && @all_states[tree] && @all_states[tree][name])
        return @all_states[tree][name]
      end
    end
    
    # 
    # returns an array of all the parent states of the passed state
    #
    def parent_states(state)
      ret = []
      curr = state
      
      ret.push(curr)
      
      curr = state_object(curr.parent_state, curr.global_concurrent_state)
      
      while(curr)
        ret.push(curr)
        curr = state_object(curr.parent_state, curr.global_concurrent_state)
      end
      
      return ret
    end
    
    # creates an array of all a states parent states
    # ending with a string of "root" to indcate the
    # root state
    def parent_states_with_root(state)
      ret = parent_states(state)
      ret.push('root')
      return ret
    end
  end #end class
end #end module
