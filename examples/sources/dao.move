/// Simple DAO Proposal State Machine Demo
/// 
/// States: Draft → Active → Passed
module ssmf::dao;
    use std::string::String;
    use ssmf::state::{Self, State};
    use ssmf::transition::{Self, TransitionCap};
    use ssmf::invariants;

    /// State markers
    public struct Draft has drop {}
    public struct Active has drop {}
    public struct Passed has drop {}

    /// Simple proposal
    public struct Proposal<phantom S> has key {
        id: UID,
        state: State<S>,
        title: String,
        votes_for: u64,
        votes_against: u64,
    }

    /// Create a new proposal in Draft state
    public fun create_proposal(
        title: String,
        ctx: &mut TxContext
    ): Proposal<Draft> {
        Proposal {
            id: object::new(ctx),
            state: state::new_state<Draft>(ctx),
            title,
            votes_for: 0,
            votes_against: 0,
        }
    }

    /// Activate proposal: Draft → Active
    public fun activate(
        proposal: Proposal<Draft>,
        cap: &TransitionCap<Draft, Active>,
        ctx: &mut TxContext
    ): Proposal<Active> {
        let new_state = transition::transition<Draft, Active>(proposal.state, cap, ctx);

        Proposal {
            id: proposal.id,
            state: new_state,
            title: proposal.title,
            votes_for: proposal.votes_for,
            votes_against: proposal.votes_against,
        }
    }

    /// Vote on active proposal
    public fun vote(proposal: &mut Proposal<Active>, approve: bool) {
        if (approve) {
            proposal.votes_for = proposal.votes_for + 1;
        } else {
            proposal.votes_against = proposal.votes_against + 1;
        }
    }

    /// Finalize proposal: Active → Passed (with guards)
    public fun finalize(
        proposal: Proposal<Active>,
        cap: &TransitionCap<Active, Passed>,
        ctx: &mut TxContext
    ): Proposal<Passed> {
        // Guard: votes_for must be greater than votes_against
        let can_pass = invariants::check_greater(
            proposal.votes_for, 
            proposal.votes_against
        );

        let new_state = invariants::guarded_transition<Active, Passed>(
            proposal.state,
            cap,
            can_pass,
            ctx
        );

        Proposal {
            id: proposal.id,
            state: new_state,
            title: proposal.title,
            votes_for: proposal.votes_for,
            votes_against: proposal.votes_against,
        }
    }

    /// View functions
    public fun votes_for<S>(proposal: &Proposal<S>): u64 {
        proposal.votes_for
    }

    public fun votes_against<S>(proposal: &Proposal<S>): u64 {
        proposal.votes_against
    }
