pragma solidity ^0.8.0;
import "Context.sol";
import "IERC20.sol";
import "Ownable.sol"; 
import "SafeMath.sol";
import "Address.sol";
import "SafeERC20.sol";
import "ERC20.sol";
import "BEP20.sol";
import "IUniswapV2Factory.sol";
import "IUniswapV2Pair.sol";
import "IUniswapV2Router01.sol";
import "IUniswapV2Router02.sol";
    contract launchpad is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for uint256;
    using Address for address;
    uint public maxCap; // max cap in ETH
    uint public immutable startTime; // start sale time
    uint public immutable endTime; // end sale time
    uint public totalFundsreceived; // total ETH received
    uint public totalParticipants; // total participants in ILO
    address payable public projectOwner; // project owner
    address public tokenAddress;
    uint public maxAllocationUser; // max allocation per user
    uint public minAllocationUser; // min allocation per user
    string private _name = "Smart Soft Studio";
    string private _symbol = "SMARTSS";
    uint8 private _decimals = 8;

    mapping(address => uint) public allContributors;

    constructor(uint _maxCap, uint _startTime, uint _endTime, uint _totalParticipants, address payable _projectOwner, address _tokenAddress) {

    maxCap = _maxCap;
    startTime = _startTime;
    endTime = _endTime;
    totalParticipants = _totalParticipants;
    projectOwner = _projectOwner;
    minAllocationUser = 0.1 ether;
    maxAllocationUser = maxCap / totalParticipants;

    require(_tokenAddress != address(0), "Zero token address"); //Adding token to the contract
    tokenAddress = _tokenAddress;
    //ERC20Interface = IERC20(tokenAddress);
    }

    function updateValues(uint _totalUserParticipants) external onlyOwner{
        totalParticipants = _totalUserParticipants;
        maxAllocationUser = maxCap / totalParticipants;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    // modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        // uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        // require(amount <= ourAllowance, "Make sure to add enough allowance");
       // _;
    // }

    receive() external payable {

     require(block.timestamp >= startTime, "The sale is not started yet ");
     require(block.timestamp <= endTime, "The sale is closed");
     require(totalFundsreceived + msg.value <= maxCap, "buyTokens: purchase would exceed max cap");
    }

    //receive() external payable {
     //   purchaseTokens();
    //}

    function purchaseTokens() public payable {
        require(block.timestamp >= startTime, "The sale is not started yet ");
        require(block.timestamp <= endTime, "The sale is closed");
        require(msg.value >= minAllocationUser, "Your purchasing power is too low");
        require(msg.value <= maxAllocationUser, "You're investing more than maximum allocation limit");
        require(totalFundsreceived + msg.value <= maxCap, "Purchase would exceed Max Cap");

        allContributors[msg.sender] += msg.value;
        totalFundsreceived += msg.value;
        sendValue(projectOwner, address(this).balance);
    }
}