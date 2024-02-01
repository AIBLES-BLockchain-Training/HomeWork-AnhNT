// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

contract NumberManager
{
    uint private TotalSum;
    uint public lastAddNumber;

    constructor (uint m, uint n) {
        TotalSum = m;
        lastAddNumber = n;
    }

    function TotalSum1 (uint number) private {
        TotalSum += number;
    }

    function addNumber (uint number) public {
        TotalSum1(number);
        lastAddNumber = number;  
    }

    function getTotalSum() external view returns (uint) {
        return TotalSum;
    }

}