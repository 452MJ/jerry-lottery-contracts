pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "./RandomGenerator.sol";


contract BettingPool is ChainlinkClient, Ownable, RandomGenerator {
    /* Type declarations */
    enum Status {
        OPEN,
        PENDING
    }

    /* State variables */
    string public name = "Jerry Token Farm";
    IERC20 public dappToken;

    uint public constant MINIMUM_BETTING_AMOUNT = 0.1 ether; // 0.1 ETH
    mapping(address => uint256) public  ownerBonusAmount;
    address[] public stakers;
    Status public lotteryStatus = Status.OPEN;
    uint public nextDrawingTime = block.timestamp + 1 hours;
    uint256 public luckyNumber;
    uint256 public random;
    // token > address
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping(address => address) public tokenPriceFeedMapping;
    address[] allowedTokens;

    /* Events */
    event AddBettingSuccess(address _from, uint amount);
    event RewardingBonusSuccess(address _to, uint amount);
    event StatusChanged(Status status);
    /* Functions */

    constructor(address _dappTokenAddress) public Ownable(){
        address jerryToken =  0x47c4748474f61b4afaa88d5225177fc861d37155;
        dappToken = IERC20(jerryToken);
    }

    /**抽奖相关**/
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


    //修改状态
    function setStatus(Status _status)
    private
    onlyOwner
    {
        lotteryStatus = _status;
        emit StatusChanged(_status);
    }

    /**Token Farm相关**/
    //设定代币币价预言机投喂合约
    function setPriceFeedContract(address token, address priceFeed)
    public
    onlyOwner
    {
        tokenPriceFeedMapping[token] = priceFeed;
    }

    //质押代币
    function stakeTokens(uint256 _amount, address token) public {
        // Require amount greater than 0
        require(_amount > 0, "amount cannot be 0");
        if (tokenIsAllowed(token)) {
            updateUniqueTokensStaked(msg.sender, token);
            IERC20(token).transferFrom(msg.sender, address(this), _amount);
            stakingBalance[token][msg.sender] =
            stakingBalance[token][msg.sender] +
            _amount;
            if (uniqueTokensStaked[msg.sender] == 1) {
                stakers.push(msg.sender);
            }
        }
    }


    //提现代币
    function unstakeTokens(address token) public {
        // Fetch staking balance
        uint256 balance = stakingBalance[token][msg.sender];
        require(balance > 0, "staking balance cannot be 0");
        IERC20(token).transfer(msg.sender, balance);
        stakingBalance[token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
    }


    function getTokenEthPrice(address token) public view returns (uint256) {
        address priceFeedAddress = tokenPriceFeedMapping[token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (
        uint80 roundID,
        int256 price,
        uint256 startedAt,
        uint256 timeStamp,
        uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price);
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
