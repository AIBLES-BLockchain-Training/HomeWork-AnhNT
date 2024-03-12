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
    uint256 constant INTEREST_RATE = 5; // Lãi suất cho vay (%)
    uint256 constant SECONDS_IN_YEAR = 31536000; // Số giây 1 năm

    struct Loan {
        address borrower;
        uint256 amount;
        uint256 startTime;
        uint256 duration; // Thời gian cho vay tính bằng giây
        uint256 interest; // Lãi phải trả
        bool repaid; // check trả nợ hay chưa
    }

    Loan[] public loans; 
    
    // check có phải user không
    function isUser(address _address) public view returns (bool) {
        return users[_address];
    }

    // Hàm cho vay tiền
    function lend(address _borrower, uint256 _amount, uint256 _duration) public onlyManager {
        require(isUser(_borrower), "Borrower is not a user");
        require(balances[_borrower] >= _amount, "Borrower does not have enough balance");
        
        uint256 interest = (_amount * INTEREST_RATE * _duration) / (100 * SECONDS_IN_YEAR); // Tính lãi phải trả
        
        loans.push(Loan({
            borrower: _borrower,
            amount: _amount,
            startTime: block.timestamp, // Thời gian hiện tại
            duration: _duration,
            interest: interest,
            repaid: false
        }));
        balances[msg.sender] -= _amount;
    }

    // Hàm trả nợ
    function repayLoan(uint256 _loanIndex) public {
        Loan storage loan = loans[_loanIndex];
        require(msg.sender == loan.borrower, "Only borrower can repay the loan");
        require(!loan.repaid, "Loan already repaid");
        uint256 totalAmount = loan.amount + loan.interest;
        balances[msg.sender] += totalAmount;
        loan.repaid = true;
    }

    // Hàm kiểm tra trạng thái của một khoản vay
    function checkLoanStatus(uint256 _loanIndex) public view returns (string memory) {
        Loan storage loan = loans[_loanIndex];
        if (loan.repaid) {
            return "Repaid";
        } else if (block.timestamp >= loan.startTime + loan.duration) {
            return "Overdue";
        } else {
            return "Active";
        }
    }
}

