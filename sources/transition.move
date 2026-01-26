/// Provides capability-based access control for state transitions

module ssmf::transition;
    use ssmf::state::{Self, State};


    public struct TransitionCap<phantom From, phantom To> has key, store {
        id: UID,
    }

    public fun new_transition_cap<From, To>(ctx: &mut TxContext): TransitionCap<From, To> {
        TransitionCap {
            id: object::new(ctx),
        }
    }

    public fun issue_transition_cap<From, To>(recipient: address, ctx: &mut TxContext) {
        let cap = new_transition_cap<From, To>(ctx);
        transfer::transfer(cap, recipient);
    }

    public fun issue_shared_cap<From, To>(ctx: &mut TxContext) {
        let cap = new_transition_cap<From, To>(ctx);
        transfer::share_object(cap);
    }

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