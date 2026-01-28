module ssmf::invariants;
    use ssmf::state::{Self, State};
    use ssmf::transition::TransitionCap;

    const E_GUARD_FAILED: u64 = 0;
    // const E_INVARIANT_VIOLATED: u64 = 1;

    /// Guard function type - returns true if transition is allowed
    /// GuardedCap adds runtime condition checking
    public struct GuardedCap<phantom From, phantom To> has key, store {
        id: UID,
    }

    public fun new_guarded_cap<From, To>(ctx: &mut TxContext): GuardedCap<From, To> {
        GuardedCap {
            id: object::new(ctx), 
        }
    }

    /// Perform a guarded transition with a custom condition (MUST return true for transition to proceed)
    public fun guarded_transition<From, To>(
        old_state: State<From>, 
        _cap: &TransitionCap<From, To>,
        guard_result: bool, 
        ctx: &mut TxContext
    ): State<To> {
        assert!(guard_result, E_GUARD_FAILED);
        state::transform<From,To>(old_state, ctx)
    }

    public fun guarded_transition_with_data<From, To>(
        old_state: State<From>,
        new_data: vector<u8>,
        _cap: &TransitionCap<From, To>,
        guard_result: bool,
        ctx: &mut TxContext
    ): State<To> {
        assert!(guard_result, E_GUARD_FAILED);
        state::transform_with_data<From, To>(old_state, new_data, ctx)
    }

    public fun check_equal(value: u64, expected: u64): bool {
        value == expected
    }

    public fun check_non_zero(value: u64): bool {
        value > 0
    }

    /// Logical AND - combine multiple guards
    public fun and(guard1: bool, guard2: bool): bool {
        guard1 && guard2
    }

    /// Logical OR - at least one guard must pass
    public fun or(guard1: bool, guard2: bool): bool {
        guard1 || guard2
    }

    /// Logical NOT - invert a guard
    public fun not(guard: bool): bool {
        !guard
    }

    /// Assert an invariant holds (aborts if false)
    public fun assert_invariant(condition: bool, error_code: u64) {
        assert!(condition, error_code);
    }

    /// Check multiple conditions at once (all must be true)
    public fun check_all(conditions: vector<bool>): bool {
        let len = vector::length(&conditions);
        let mut i = 0;
        
        while (i < len) {
            if (!*vector::borrow(&conditions, i)) {
                return false
            };
            i = i + 1;
        };
        
        true
    }

    /// Check if any condition is true (at least one must be true)
    public fun check_any(conditions: vector<bool>): bool {
        let len = vector::length(&conditions);
        let mut i = 0;
        
        while (i < len) {
            if (*vector::borrow(&conditions, i)) {
                return true
            };
            i = i + 1;
        };
        
        false
    }

    #[test_only]
    public fun test_new_guarded_cap<From, To>(
        ctx: &mut TxContext
    ): GuardedCap<From, To> {
        new_guarded_cap<From, To>(ctx)
    }
