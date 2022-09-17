// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Get funds from users
// Withdraw funds
// Set a min value
import "./PriceConverter.sol";

error NotOwner();

// here it is outside of the contract
contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 **18 ->**expo Constant is cheap

    address[] public funders;
    // depolyed time it set the values imeditelly  ->create
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender; // only here the msg.sender so immutable can be
    }

    // without constant 837273
    // with constant 817,731
    // address to each them send
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        // want to be able to set a min fund amount in USD
        //1. how to send eth to this contract ->by value

        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough"
        ); // 1e18 == 1 * 10 ** 18 == 1000000000000000000  it has 18 decimal place wei(default)
        funders.push(msg.sender);
        //key = value
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            // key
            address funder = funders[funderIndex];
            // key : value
            addressToAmountFunded[funder] = 0;
        }
        // reset array
        funders = new address[](0);
        // send money -> 3 methods
        // transfer
        //send
        //call

        // msg.sender = address so,
        //transfer -> type cast to payable address
        // to send the native token like eth then it must be payable address
        // this means for this contract this instance
        // msg.sender we get the address to send.
        //       payable(msg.sender).transfer(address(this).balance); // if more gas then error also revert the transation
        // // send
        //  bool sendSuccess = payable(msg.sender).send(address(this).balance); // it not revert but return a bool
        //       // so to revert add
        //       require(sendSuccess,"Send Failed"); // not it reverted it the sendsucess is false.
        //call without even needed the ABI
        // it return 2 valable so,
        // if the fun is sucess data is stored in data returs
        // also bytes are array so data returns by the memory -> mostly used    
        /*(bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");*/
        
        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner,"Sender is not owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _; // rest of the code
    }

   /*
   // if money is send accedently we can process then the fund will automatically
    // without even calling the fund function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }*/
}
