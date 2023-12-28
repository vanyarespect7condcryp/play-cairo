%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_eq,
    uint256_mul,
    uint256_unsigned_div_rem,
)

from openzeppelin.token.erc20.library import ERC20
from openzeppelin.token.erc20.IERC20 import IERC20

@storage_var
func token() -> (address : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_address : felt
):
    let name = 'Liquidity Provider Token'
    let symbol = 'LP-TKN'
    let decimals = 18

    ERC20.initializer(name, symbol, decimals)

    token.write(token_address)

    return ()
end

@external
func deposit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : Uint256):
    alloc_locals

    with_attr error_message("Vault: Amount cannot be 0"):
        let (is_amount_zero) = uint256_eq(amount, Uint256(0, 0))
        assert is_amount_zero = FALSE
    end

    let (token_address) = token.read()
    let (caller_address) = get_caller_address()
    let (contract_address) = get_contract_address()

    let amount_token : Uint256 = amount
    let (supply_lp_token) = IERC20.totalSupply(contract_address)
    let (balance_token) = IERC20.balanceOf(token_address, contract_address)

    let (is_lp_token_supply_zero) = uint256_eq(supply_lp_token, Uint256(0, 0))

    if is_lp_token_supply_zero == TRUE:
        let amount_lp_token = amount_token
        ERC20._mint(caller_address, amount_lp_token)
    else:
        let (res_mul, carry) = uint256_mul(amount_token, supply_lp_token)
        let (amount_lp_token, remainder) = uint256_unsigned_div_rem(res_mul, balance_token)
        ERC20._mint(caller_address, amount_lp_token)
    end

    IERC20.transferFrom(token_address, caller_address, contract_address, amount)

    return ()
end

@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : Uint256):
    alloc_locals

    with_attr error_message("Vault: Amount cannot be 0"):
        let (is_amount_zero) = uint256_eq(amount, Uint256(0, 0))
        assert is_amount_zero = FALSE
    end

    let (token_address) = token.read()
    let (caller_address) = get_caller_address()
    let (contract_address) = get_contract_address()

    let amount_lp_token = amount
    let (supply_lp_token) = IERC20.totalSupply(contract_address)
    let (balance_token) = IERC20.balanceOf(token_address, contract_address)

    let (res_mul, carry) = uint256_mul(amount_lp_token, balance_token)
    let (amount_token, remainder) = uint256_unsigned_div_rem(res_mul, supply_lp_token)

    ERC20._burn(caller_address, amount_lp_token)
    IERC20.transfer(token_address, caller_address, amount_token)

    return ()
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end

@view
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    totalSupply : Uint256
):
    let (totalSupply : Uint256) = ERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    decimals : felt
):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (balance : Uint256):
    let (balance : Uint256) = ERC20.balance_of(account)
    return (balance)
end

@view
func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt
) -> (remaining : Uint256):
    let (remaining : Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end

#
# Externals
#

@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    recipient : felt, amount : Uint256
) -> (success : felt):
    ERC20.transfer(recipient, amount)
    return (TRUE)
end

@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> (success : felt):
    ERC20.transfer_from(sender, recipient, amount)
    return (TRUE)
end

@external
func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    ERC20.approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, added_value : Uint256
) -> (success : felt):
    ERC20.increase_allowance(spender, added_value)
    return (TRUE)
end

@external
func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, subtracted_value : Uint256
) -> (success : felt):
    ERC20.decrease_allowance(spender, subtracted_value)
    return (TRUE)
end
