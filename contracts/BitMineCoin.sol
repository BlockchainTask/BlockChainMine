pragma solidity ^0.4.18;

//import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "./TokenERC20.sol";


contract BitMineCoin is TokenERC20{
	address public _owner;
	address public _mine_pool_locked_address;

	function BitMineCoin() public{
		_mine_pool_locked_address = address(100);
		_owner = msg.sender;
		//locked to an empty address, no one can control.
		balanceOf[_mine_pool_locked_address] = totalSupply-2100000*(10 ** uint256(decimals)); 
		//use to reward to active players in early period.
		balanceOf[_owner] = 2100000*(10 ** uint256(decimals)); 
	}
}
