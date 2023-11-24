module startrek_poap::startrek {

    use std::option;
    use sui::tx_context::{Self, TxContext};
    use sui::coin;
    use sui::transfer;
    // use sui::coin::{Self, TreasuryCap};
    // use sui::object::UID;

    struct STARTREK has drop {}

    // struct Treasury has key {
    //     id: UID,
    //     treasury_cap: TreasuryCap<STARTREK>,
    // }

    fun init(otw: STARTREK, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<STARTREK>(
            otw,
            9,
            b"STK",
            b"Startrek Coin",
            b"learn to earn",
            option::none(),
            ctx,
        );
        let deployer = tx_context::sender(ctx);

        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, deployer);
    }
}