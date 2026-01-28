/// Provides capability-based access control for state transitions

module ssmf::transition;
    use ssmf::state::{Self, State};


    // Capability that authorizes a specific state transition
    /// TransitionCap provides compile-time type safety
    public struct TransitionCap<phantom From, phantom To> has key, store {
        id: UID,
    }

    /// Creates new transition capability that grants permission to transition from state From to state To
    public fun new_transition_cap<From, To>(ctx: &mut TxContext): TransitionCap<From, To> {
        TransitionCap {
            id: object::new(ctx),
        }
    }

    /// Issue a transition capability to a specific address
    public fun issue_transition_cap<From, To>(recipient: address, ctx: &mut TxContext) {
        let cap = new_transition_cap<From, To>(ctx);
        transfer::transfer(cap, recipient);
    }

    /// Issue a shared transition capability (anyone can use it)
    public fun issue_shared_cap<From, To>(ctx: &mut TxContext) {
        let cap = new_transition_cap<From, To>(ctx);
        transfer::share_object(cap);
    }

    /// Perform a state transition using a capability
    /// The capability proves that this transition is allowed
    /// Consumes the old state and returns a new state with the new type
    public fun transition<From, To>(
        old_state: State<From>, 
        _cap: &TransitionCap<From, To>, 
        ctx: &mut TxContext
        ): State<To> {
            state::transform<From,To>(old_state, ctx)
            }

    public fun transition_with_data<From,To>(
        old_state: State<From>, 
        new_data: vector<u8>,
        _cap: &TransitionCap<From, To>, 
        ctx: &mut TxContext
        ): State<To> {
            state::transform_with_data<From,To>(old_state, new_data, ctx)
            }

    /// Destroy a transition capability (revoke permission)
    public fun revoke_cap<From, To>(cap: TransitionCap<From, To>) {
        let TransitionCap { id } = cap;
        object::delete(id);
    }

    public fun cap_uid<From, To>(cap: &TransitionCap<From, To>): &UID {
        &cap.id
    }

    #[test_only]
    /// Test helper to create a capability
    public fun test_new_cap<From, To>(ctx: &mut TxContext): TransitionCap<From, To> {
        new_transition_cap<From, To>(ctx)
    }