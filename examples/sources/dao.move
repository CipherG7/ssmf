/// Simple DAO Proposal State Machine Demo
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

    /// Proposal wrapper - holds the state machine
    /// Note: We only store the State, not the whole proposal as an object
    public struct Proposal has key, store {
        id: UID,
        title: String,
        votes_for: u64,
        votes_against: u64,
    }

    /// Create a new proposal in Draft state
    public fun create_proposal(
        title: String,
        ctx: &mut TxContext
    ): (Proposal, State<Draft>) {
        let proposal = Proposal {
            id: object::new(ctx),
            title,
            votes_for: 0,
            votes_against: 0,
        };
        
        let state = state::new_state<Draft>(ctx);
        
        (proposal, state)
    }

    /// Activate proposal: Draft → Active
    public fun activate(
        state: State<Draft>,
        cap: &TransitionCap<Draft, Active>,
        ctx: &mut TxContext
    ): State<Active> {
        transition::transition<Draft, Active>(state, cap, ctx)
    }

    /// Vote on active proposal
    public fun vote(proposal: &mut Proposal, approve: bool) {
        if (approve) {
            proposal.votes_for = proposal.votes_for + 1;
        } else {
            proposal.votes_against = proposal.votes_against + 1;
        }
    }

    /// Finalize proposal: Active → Passed (with guards)
    public fun finalize(
        proposal: &Proposal,
        state: State<Active>,
        cap: &TransitionCap<Active, Passed>,
        ctx: &mut TxContext
    ): State<Passed> {
        // Guard: votes_for must be greater than votes_against
        let can_pass = proposal.votes_for > proposal.votes_against;

        // Guarded transition
        invariants::guarded_transition<Active, Passed>(
            state,
            cap,
            can_pass,
            ctx
        )
    }

    public fun votes_for(proposal: &Proposal): u64 {
        proposal.votes_for
    }

    public fun votes_against(proposal: &Proposal): u64 {
        proposal.votes_against
    }
    
    public fun title(proposal: &Proposal): String {
        proposal.title
    }
