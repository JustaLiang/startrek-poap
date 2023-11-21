module startrek_poap::poap {

    use std::string::String;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    const POAP_PRICE: u64 = 1_000_000_000;
    const BENEFICIARY: address = @0x95b0ce9775382b88a4e698d31a0a7fd796922c91bb80de66e940bd4cae5a9916;

    const ENotEnough: u64 = 0;

    struct StartrekPOAP has key {
        id: UID,
        name: String,
    }

    struct MintCap has key, store {
        id: UID,
        mint_count: u64,
    }

    fun init(ctx: &mut TxContext) {
        let mint_cap = MintCap {
            id: object::new(ctx),
            mint_count: 0,
        };
        let deployer = tx_context::sender(ctx);
        transfer::transfer(mint_cap, deployer);
    }

    public fun new_poap(
        cap: &mut MintCap,
        name: String,
        ctx: &mut TxContext,
    ): StartrekPOAP {
        cap.mint_count = cap.mint_count + 1;
        StartrekPOAP {
            id: object::new(ctx),
            name,
        }
    }

    entry fun create_poap(
        cap: &mut MintCap,
        name: String,
        to: address,
        ctx: &mut TxContext,
    ) {
        let poap = new_poap(cap, name, ctx);
        transfer::transfer(poap, to);
    }

    entry fun buy_poap(
        coin: Coin<SUI>,
        name: String,
        ctx: &mut TxContext,
    ) {
        let coin_value = coin::value(&coin);
        // let coin_value = coin.balance.value;
        assert!(coin_value == POAP_PRICE, ENotEnough);
        let poap = StartrekPOAP {
            id: object::new(ctx),
            name,
        };
        let buyer = tx_context::sender(ctx);
        transfer::transfer(poap, buyer);
        transfer::public_transfer(coin, BENEFICIARY);
    }

    entry fun create_mint_cap(
        _: &MintCap,
        to: address,
        ctx: &mut TxContext,
    ) {
        let mint_cap = MintCap {
            id: object::new(ctx),
            mint_count: 0,
        };
        transfer::transfer(mint_cap, to);
    }
}

// capability
// T, &T, &mut T
// key, store
// copy, drop