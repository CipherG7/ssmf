/// SUI STATE MACHINE FRAMEWORK - State module
/// Use phantom types to make invalid states unrepresentable during compile time

module ssmf::state;

    /// T is a phantom type representing the current state
    public struct State<phantom T> has key, store{
        id: UID,
        data: vector<u8>,
    }

    /// Create a new state machine in its initial state
    public fun new_state<T>(ctx:&mut TxContext): State<T> {
        State {
            id: object::new(ctx),
            data: vector::empty(),
        }
    }

    /// Create a new state machine with the given initial data
    public fun new_state_with_data<T>(data: vector<u8>, ctx:&mut TxContext): State<T> {
        State {
            id: object::new(ctx),
            data,
        }
    }

    /// Get the state's UID 
    public fun uid<T>(state: &State<T>): &UID {
        &state.id
    }

    /// Get a mutable reference to the state's UID
    public fun uid_mut<T>(state: &mut State<T>): &mut UID {
        &mut state.id
    }

    /// Get a reference to the state's data
    public fun data<T>(state: &State<T>): &vector<u8> {
        &state.data
    }

    /// Update the state's data
    public fun update_data<T>(state: &mut State<T>, new_data: vector<u8>) {
        state.data = new_data;
    }

    /// Transform state type by consuming old state and creating new one
    /// This is the KEY function for type-safe transitions
    /// Creates a new UID because Sui doesn't allow UID reuse
    public fun transform<From, To>(
        old_state: State<From>, 
        ctx: &mut TxContext
    ): State<To> {
        let State { id, data } = old_state;
        object::delete(id);  
    
        State {
            id: object::new(ctx),
            data,
        }
    }

    /// Transform with new data
    public fun transform_with_data<From, To>(
        old_state: State<From>,
        new_data: vector<u8>,
        ctx: &mut TxContext
    ): State<To> {
        let State { id, data: _ } = old_state;
        object::delete(id);
        
        State {
            id: object::new(ctx),
            data: new_data,
        }
    }

    ///Extract data and destroy the state
    public fun extract_data<T>(state: State<T>): vector<u8> {
        let State { id, data} = state;
        object::delete(id);
        data
    }

    /// Destroy the state machine (Terminal states only)
    public fun destroy<T>(state: State<T>) {
        let State { id, data: _ } = state;
        object::delete(id);
    }

    #[test_only]
    /// Test helper to create a state for testing
    public fun test_new<T>(ctx: &mut TxContext): State<T> {
        new_state<T>(ctx)
    }