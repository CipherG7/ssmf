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

    /// Destroy the state machine (Terminal states only)
    public fun destroy<T>(state: State<T>) {
        let State { id, data: _ } = state;
        object::delete(id);
    }
