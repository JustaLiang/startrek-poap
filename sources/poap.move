// Summary
// 1. Ability
// 2. Capability
// 3. Hot potato (ex: Flash loans)
module startrek_poap::poap {

    use std::string::String;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    // use sui::sui::SUI;
    use startrek_poap::startrek::STARTREK;

    const POAP_PRICE: u64 = 1_000_000_000;

    const ENotEnough: u64 = 0;
    const ERepaymentNotEnough: u64 = 1;

    struct StartrekPOAP has key {
        id: UID,
        name: String,
    }

    struct Treasury has key {
        id: UID,
        balance: Balance<STARTREK>,
    }

    struct FlashLoanReceipt {
        loan_amount: u64,
    }

    struct MintCap has key, store {
        id: UID,
        mint_count: u64,
    }

    struct WithdrawCap has key, store {
        id: UID,
    }

    fun init(ctx: &mut TxContext) {
        let mint_cap = MintCap {
            id: object::new(ctx),
            mint_count: 0,
        };
        let withraw_cap = WithdrawCap {
            id: object::new(ctx),
        };
        let deployer = tx_context::sender(ctx);
        transfer::transfer(mint_cap, deployer);
        transfer::transfer(withraw_cap, deployer);
        let treasury = Treasury {
            id: object::new(ctx),
            balance: balance::zero(),
        };
        transfer::share_object(treasury);
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
        treasury: &mut Treasury,
        coin: Coin<STARTREK>,
        name: String,
        to: address,
        ctx: &mut TxContext,
    ) {
        let coin_value = coin::value(&coin);
        // let coin_value = coin.balance.value;
        assert!(coin_value == POAP_PRICE, ENotEnough);
        let poap = StartrekPOAP {
            id: object::new(ctx),
            name,
        };
        transfer::transfer(poap, to);
        coin::put(&mut treasury.balance, coin);
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

    entry fun withdraw_to(
        _: &WithdrawCap,
        treasury: &mut Treasury,
        amount: u64,
        to: address,
        ctx: &mut TxContext,
    ) {
        let fund = coin::take(&mut treasury.balance, amount, ctx);
        transfer::public_transfer(fund, to);
    }

    public fun flash_borrow(
        treasury: &mut Treasury,
        amount: u64,
        ctx: &mut TxContext,
    ): (Coin<STARTREK>, FlashLoanReceipt) {
        let loan = coin::take(&mut treasury.balance, amount, ctx);
        let receipt = FlashLoanReceipt { loan_amount: amount };
        (loan, receipt)
    }

    public fun flash_repay(
        treasury: &mut Treasury,
        repayment: Coin<STARTREK>,
        receipt: FlashLoanReceipt,
    ) {
        let FlashLoanReceipt { loan_amount } = receipt;
        assert!(coin::value(&repayment) >= loan_amount, ERepaymentNotEnough);
        coin::put(&mut treasury.balance, repayment);
    }

    // other modules
    public fun arbitrage(
        treasury: &mut Treasury,
        // ...
        ctx: &mut TxContext,
    ) {
        let (loan, receipt) = flash_borrow(treasury, 1_000_000_000, ctx);
        // ...
        flash_repay(treasury, loan, receipt);
    }
}

// capability
// T, &T, &mut T
// key, store
// copy, drop

