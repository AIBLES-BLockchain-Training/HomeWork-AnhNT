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

contract LoanManagement is Moneymanagement {
    address public admin;
    mapping(address => bool) public users;
    uint256 public interestRate;
    
    event Borrow(address indexed user, uint256 amount, uint256 months, uint256 interest, uint256 totalPayment);
    event Repay(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this operation");
        _;
    }

    constructor(uint256 _interestRate) {
        admin = msg.sender;
        interestRate = _interestRate;
    }

    function registerUser() external {
        users[msg.sender] = true;
    }

    function setInterestRate(uint256 _interestRate) external onlyAdmin {
        require(_interestRate >= 0, "Interest rate must be non-negative");
        interestRate = _interestRate;
    }

    function calculateInterest(uint256 _principal, uint256 _months) public view returns (uint256) {
        uint256 monthlyRate = (_principal * interestRate * _months) / (12 * 100);
        return monthlyRate;
    }

    function borrow(uint256 _amount, uint256 _months) external payable {
        require(users[msg.sender], "Only registered users can borrow");
        require(_amount > 0, "Borrowed amount must be greater than 0");

        uint256 totalInterest = calculateInterest(_amount, _months);
        uint256 totalPayment = _amount + totalInterest;
        
        require(msg.value >= totalPayment, "Insufficient funds to cover borrowed amount and interest");

        emit Borrow(msg.sender, _amount, _months, totalInterest, totalPayment);
    }

    function repayLoan() external payable {
        // Logic to handle repayment
        emit Repay(msg.sender, msg.value);
    }
}
