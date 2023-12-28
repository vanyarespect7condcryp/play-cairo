%lang starknet

from openzeppelin.token.erc20.IERC20 import IERC20
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub

@contract_interface
namespace IMockERC20:
    func mint(to_address : felt, amount : Uint256):
    end
end

@contract_interface
namespace IVault:
    func deposit(amount : Uint256):
    end

    func withdraw(amount : Uint256):
    end

    func balanceOf(account : felt) -> (balance : Uint256):
    end

    func approve(spender : felt, amount : Uint256) -> (success : felt):
    end
end

@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{ context.alice = 12345 %}
    %{ context.bob = 67890 %}

    let name = 'Token'
    let symbol = 'TKN'
    let decimals = 18

    %{ context.token_address = deploy_contract("./tests/utils/mock_erc20.cairo", [ids.name, ids.symbol, ids.decimals]).contract_address %}
    %{ context.vault_address = deploy_contract("./src/vault.cairo", [context.token_address]).contract_address %}

    tempvar alice
    tempvar bob
    tempvar token_address
    %{ ids.alice = context.alice %}
    %{ ids.bob = context.bob %}
    %{ ids.token_address = context.token_address %}

    let amount = Uint256(low=100, high=0)

    # Mint Alice 100 TKN
    IMockERC20.mint(contract_address=token_address, to_address=alice, amount=amount)

    # Mint Bob 100 TKN
    IMockERC20.mint(contract_address=token_address, to_address=bob, amount=amount)

    return ()
end

@external
func test_end_to_end{syscall_ptr : felt*, range_check_ptr}():
    tempvar alice
    tempvar bob
    tempvar token_address
    tempvar vault_address
    %{ ids.alice = context.alice %}
    %{ ids.bob = context.bob %}
    %{ ids.token_address = context.token_address %}
    %{ ids.vault_address = context.vault_address %}

    # Alice deposits 10 TKN
    %{ stop_prank_alice = start_prank(caller_address=context.alice, target_contract_address=context.token_address) %}
    let amount = Uint256(low=10, high=0)
    IERC20.approve(contract_address=token_address, spender=vault_address, amount=amount)
    %{ stop_prank_alice() %}
    %{ stop_prank_alice = start_prank(caller_address=context.alice, target_contract_address=context.vault_address) %}
    IVault.deposit(contract_address=vault_address, amount=amount)
    %{ stop_prank_alice() %}

    let (lp_token_balance) = IVault.balanceOf(contract_address=vault_address, account=alice)
    assert lp_token_balance = Uint256(low=10, high=0)
    let (token_balance_alice) = IERC20.balanceOf(contract_address=token_address, account=alice)
    let (result) = uint256_sub(Uint256(low=100, high=0), Uint256(low=10, high=0))
    assert token_balance_alice = result
    let (token_balance_vault) = IERC20.balanceOf(
        contract_address=token_address, account=vault_address
    )
    assert token_balance_vault = Uint256(low=10, high=0)

    # Bob deposits 20 TKN
    %{ stop_prank_bob = start_prank(caller_address=context.bob, target_contract_address=context.token_address) %}
    let amount = Uint256(low=20, high=0)
    IERC20.approve(contract_address=token_address, spender=vault_address, amount=amount)
    %{ stop_prank_bob() %}
    %{ stop_prank_bob = start_prank(caller_address=context.bob, target_contract_address=context.vault_address) %}
    IVault.deposit(contract_address=vault_address, amount=amount)
    %{ stop_prank_bob() %}

    let (lp_token_balance) = IVault.balanceOf(contract_address=vault_address, account=bob)
    assert lp_token_balance = Uint256(low=20, high=0)
    let (token_balance_bob) = IERC20.balanceOf(contract_address=token_address, account=bob)
    let (result) = uint256_sub(Uint256(low=100, high=0), Uint256(low=20, high=0))
    assert token_balance_bob = result
    let (token_balance_vault) = IERC20.balanceOf(
        contract_address=token_address, account=vault_address
    )
    assert token_balance_vault = Uint256(low=30, high=0)

    # Fees accumulate
    let amount = Uint256(low=30, high=0)
    IMockERC20.mint(contract_address=token_address, to_address=vault_address, amount=amount)
    let (token_balance_vault) = IERC20.balanceOf(
        contract_address=token_address, account=vault_address
    )
    assert token_balance_vault = Uint256(low=60, high=0)

    # Alice withdraws
    %{ stop_prank_alice = start_prank(caller_address=context.alice, target_contract_address=context.vault_address) %}
    let amount = Uint256(low=10, high=0)
    IVault.approve(contract_address=vault_address, spender=vault_address, amount=amount)
    IVault.withdraw(contract_address=vault_address, amount=amount)
    %{ stop_prank_alice() %}

    let (lp_token_balance) = IVault.balanceOf(contract_address=vault_address, account=alice)
    assert lp_token_balance = Uint256(low=0, high=0)
    let (token_balance_alice) = IERC20.balanceOf(contract_address=token_address, account=alice)
    let (result_sub) = uint256_sub(Uint256(low=100, high=0), Uint256(low=10, high=0))
    let (result, _) = uint256_add(result_sub, Uint256(low=20, high=0))
    assert token_balance_alice = result
    let (token_balance_vault) = IERC20.balanceOf(
        contract_address=token_address, account=vault_address
    )
    assert token_balance_vault = Uint256(low=40, high=0)

    # Bob withdraws
    %{ stop_prank_bob = start_prank(caller_address=context.bob, target_contract_address=context.vault_address) %}
    let amount = Uint256(low=20, high=0)
    IVault.approve(contract_address=vault_address, spender=vault_address, amount=amount)
    IVault.withdraw(contract_address=vault_address, amount=amount)
    %{ stop_prank_bob() %}

    let (lp_token_balance) = IVault.balanceOf(contract_address=vault_address, account=bob)
    assert lp_token_balance = Uint256(low=0, high=0)
    let (token_balance_bob) = IERC20.balanceOf(contract_address=token_address, account=bob)
    let (result_sub) = uint256_sub(Uint256(low=100, high=0), Uint256(low=20, high=0))
    let (result, _) = uint256_add(result_sub, Uint256(low=40, high=0))
    assert token_balance_bob = result
    let (token_balance_vault) = IERC20.balanceOf(
        contract_address=token_address, account=vault_address
    )
    assert token_balance_vault = Uint256(low=0, high=0)

    return ()
end
