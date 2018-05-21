pragma solidity ^0.4.18;

import "./BitMineCoin.sol";

contract MiningBase is BitMineCoin{

  	// CEO address Used to award and handle exceptions;
	address public _ceo_address;

	// The current status of the program
	bool public paused = false;

    function MiningBase() public{
        _ceo_address = msg.sender;
    }
    //only operated by owner
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    //only operated by ceo
    modifier onlyCeo() {
        require(msg.sender == _ceo_address);
        _;
    }
    //the program is operating normally
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    //pause programe
    function pauseProgram() public onlyOwner{
        paused = true;
    }
    //resume program
    function resumeProgram() public onlyOwner{
        paused = false;
    }
    //set ceo address
    bool ceo_address_status = true;
    function setCEOAddress(address ad) public onlyOwner{
        require(ceo_address_status);
        ceo_address_status = false;
        _ceo_address = ad;
    }
    /*
    function destory() public onlyOwner{
        suicide(_owner);
    }
    function getNowTime() public view returns(uint32){
        return uint32(now);
    }
    function getCurDayZeroTime() public view returns(uint32){
        return uint32(now / 1 days * 1 days);
    }
    */
    struct MineType {
        address owner;
        uint32 begin_mine_time; //mining machine trading time
        uint8 mine_type; //type of mine reference to different calculations
        uint8 mine_status; // 0:narmall , 1:in the eth market place
        uint256 eth_price;
        uint32 market_time;
    }

    //save all mines
    MineType[] public all_mines;
    function getAllMinesCount() public view returns(uint32){
        return uint32(all_mines.length);
    }
    uint32 public all_mines_price_count = 0; //calculate estimat income, estimated income and actual income are not equal

    struct UserInfo{
        uint32 mines_count;
        uint32 sale_mines_count;
        uint32 mines_price_count; //Equivalent to the number of single-core mineralizers
        uint256 yestoday_earn_coin;
        uint256 all_earn_coin;
    }
    mapping(address=>UserInfo) public all_users_info;

    //use to ranking,use to traverse all users.
    mapping(address=>uint8) public user_regist_status;
    address[] public all_users_address;
    function insertNewUser(address user) internal returns(uint32){
        if(user_regist_status[user]==1){
            return 0;
        }
        user_regist_status[user] = 1;
        all_users_address.push(user);
    }
    function getUserInfo(uint32 idx) public view returns(address,uint32,uint32,uint32,uint256,uint256){
        UserInfo storage user = all_users_info[all_users_address[idx]];
        return(all_users_address[idx],user.mines_count,user.sale_mines_count,user.mines_price_count,user.yestoday_earn_coin,balanceOf[all_users_address[idx]]);
    }
    //the count of different types mining machines
    mapping (uint32 => uint32) public mine_type_count;
    //saling mines count of current
    mapping (uint32 => uint32) public saling_mine_type_count;

    function getYestodayCoinNum() public view returns(uint256){
        return all_users_info[msg.sender].yestoday_earn_coin;
    }
    struct AfterSaleEarnCoinRecord {
        address owner;
        uint32 earn_times; //The mine machine produces a profit in ten minutes
        uint8 mine_type;
    }
    //save the proceeds of the player before selling
    AfterSaleEarnCoinRecord[] public sale_earn_records;
    
    function userOpenSaleSystemMine() public returns(uint32);
    event refresh();
}
