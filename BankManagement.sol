// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseUserManagement {
  address public admin; // khai báo địa chỉ cho admin

  mapping(address => bool) public managers;
  mapping(address => bool) public users;

  constructor() {
      admin = msg.sender; // gán người gọi contract là admin, khi ai đó gọi contract thì sẽ mặc định là admin
  }

  modifier onlyAdmin {
      require(msg.sender == admin, "Only admin can perform this action");
      _;
  }

  modifier onlyManager {
      require(managers[msg.sender] || msg.sender == admin, "Only manager can perform this action");
      _;
  }

  function addManager(address _manager) public onlyAdmin {
      managers[_manager] = true;
  }

  function removeManager(address _manager) public onlyAdmin {
      managers[_manager] = false;
  }

  function addUser(address _user) public onlyManager {
      users[_user] = true;
  }

  function removeUser(address _user) public onlyManager {
      users[_user] = false;
  }

  function checkUserRole(address _user) public view returns (string memory) {
      if (admin == _user) {
          return "Admin";
      } else if (managers[_user]) {
          return "Manager";
      } else if (users[_user]) {
          return "User";
      } else {
          return "Unknown";
      }
  }
}
contract MoneyManagement is BaseUserManagement {

   mapping(address => uint) public balances; //

// hàm gửi tiền
   function deposit() public payable  {
       balances[msg.sender] += msg.value;
   }

// hàm rút tiền
   function withDraw (uint amount) public {
       require(balances[msg.sender] >= amount, "Cannot withdraw money");
       balances[msg.sender] -= amount;
       payable(msg.sender).transfer(amount);
   }
}

contract LoanSystem is MoneyManagement {
    mapping(address => uint256) public loans;

    function borrow(address _borrower, uint256 _amount) public onlyManager {
        require(balances[_borrower] >= _amount, "Insufficient funds for borrowing");
        loans[_borrower] += _amount;
        balances[_borrower] -= _amount;
    }

    function repay(address _borrower, uint256 _amount) public onlyManager {
        require(loans[_borrower] >= _amount, "Cannot repay more than borrowed");
        loans[_borrower] -= _amount;
        balances[_borrower] += _amount;
    }
}
