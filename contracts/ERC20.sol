pragma solidity ^0.8.19;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyNFT is ERC20 {

    constructor() ERC20("MYTOKEN", "MTKN") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}
