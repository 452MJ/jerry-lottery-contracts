pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./RandomGenerator.sol";


contract BettingPool is RandomGenerator {
    /* Type declarations */
    enum Status {
        OPEN,
        PENDING
    }

    /* State variables */
    uint public constant MINIMUM_BETTING_AMOUNT = 0.1 ether; // 0.1 ETH
    mapping(address => uint256) public  ownerBonusAmount;
    address[] public stakers;
    Status public lotteryStatus = Status.OPEN;
    uint public nextDrawingTime = block.timestamp + 1 hours;
    uint256 public luckyNumber;
    uint256 public random;

    /* Events */
    event AddBettingSuccess(address _from, uint amount);
    event RewardingBonusSuccess(address _to, uint amount);
    event StatusChanged(Status status);
    /* Functions */

    constructor() public Ownable(){
    }

    //投注
    function addBonus()
    public
    payable
    {
        //检查金额是否＞=最小投注ETH
        require(msg.value >= MINIMUM_BETTING_AMOUNT);
        //检查是否参与过本轮抽奖
        require(ownerBonusAmount[msg.sender] <= 0);
        //登记投注金额
        ownerBonusAmount[msg.sender] = msg.value;
        //登记投注人
        stakers.push(msg.sender);
        emit AddBettingSuccess(msg.sender, msg.value);
    }

    //投注
    function transferBonusToWinner()
    public
    payable
    onlyOwner
    {
        require(lotteryStatus == Status.PENDING);
        uint balance = address(this).balance;
        address winner = stakers[luckyNumber];
        payable(winner).transfer(balance);

        for (uint256 i; i < stakers.length; i++) {
            delete ownerBonusAmount[stakers[i]];
        }
        stakers = new address[](0);
        emit RewardingBonusSuccess(winner, balance);
        setStatus(Status.OPEN);
    }


    //开奖
    function drawingLuckyNumber()
    external
    onlyOwner
    {
        require(lotteryStatus == Status.OPEN);
        require(stakers.length >= 0);
        random = getRandomNumber();
        luckyNumber = random % stakers.length;
        setStatus(Status.PENDING);
    }


    function setStatus(Status _status)
    private
    onlyOwner
    {
        lotteryStatus = _status;
        emit StatusChanged(_status);
    }

    /* Getter Functions */

    //总投注金额
    function getTotalBonus()
    public
    view
    returns (uint256) {
        uint256 total = 0;
        for (uint256 i; i < stakers.length; i++) {
            total += ownerBonusAmount[stakers[i]];
        }
        return total;
    }

}
