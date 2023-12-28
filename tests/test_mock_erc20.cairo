%lang starknet

from starkware.cairo.common.uint256 import Uint256
from openzeppelin.token.erc20.IERC20 import IERC20

@contract_interface
namespace IMockERC20:
    func mint(to_address : felt, amount : Uint256):
    end

    func burn(from_address : felt, amount : Uint256):
    end
end

@external
func __setup__():
    let name = 'Token'
    let symbol = 'TKN'
    let decimals = 18

    %{ context.contract_address = deploy_contract("./tests/utils/mock_erc20.cairo", [ids.name, ids.symbol, ids.decimals]).contract_address %}

    return ()
end

@external
func test_constructor{syscall_ptr : felt*, range_check_ptr}():
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    let (name) = IERC20.name(contract_address=contract_address)
    let (symbol) = IERC20.symbol(contract_address=contract_address)
    let (decimals) = IERC20.decimals(contract_address=contract_address)

    assert name = 'Token'
    assert symbol = 'TKN'
    assert decimals = 18

    return ()
end

@external
func test_mint{syscall_ptr : felt*, range_check_ptr}():
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    let to_address = 12345
    let amount = Uint256(low=10, high=0)

    IMockERC20.mint(contract_address=contract_address, to_address=to_address, amount=amount)

    let (balance) = IERC20.balanceOf(contract_address=contract_address, account=to_address)

    assert balance = amount

    return ()
end

@external
func test_burn{syscall_ptr : felt*, range_check_ptr}():
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    let from_address = 12345
    let amount = Uint256(low=10, high=0)

    IMockERC20.mint(contract_address=contract_address, to_address=from_address, amount=amount)

    IMockERC20.burn(contract_address=contract_address, from_address=from_address, amount=amount)
    let (balance) = IERC20.balanceOf(contract_address=contract_address, account=from_address)
    assert balance = Uint256(low=0, high=0)

    return ()
end
