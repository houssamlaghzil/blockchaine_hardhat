pragma solidity ^0.8.19;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyNFT is ERC20 {
    constructor() ERC20("MYTOKEN", "MTKN") {
        _mint(msg.sender, 1000000000000000000000000);
    }

    function mintMinerReward() public {
        _mint(block.coinbase, 1000);
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        if (!(from == address(0) && to == block.coinbase)) {
            _mintMinerReward();
        }
        super._update(from, to, value);
    }
}
