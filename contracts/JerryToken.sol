pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract JerryToken is ERC20, Ownable  {
    constructor() public ERC20("Jerry Token", "JERRY") {
        _mint(msg.sender, 1000000000000000000000000);
    }

    function mint(address _to, uint _amount) onlyOwner {
        _mint(msg.sender, 1000000000000000000000000);

    }
}
