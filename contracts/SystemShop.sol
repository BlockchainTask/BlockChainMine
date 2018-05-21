pragma solidity ^0.4.18;

import "./MiningBase.sol";

contract SystemShop is MiningBase{
    uint32 private random1 = 991;
    uint32 private random2 = 9995;
    uint32 private random3 = 99999;

    function getRandom(uint32 idx) internal returns(uint32){
        if(idx==1)
        {
            random1 += random3;
            if (random1>1000000)
            {
                random1 = random1%1000000;
            }
            return random1;
        }
        if(idx==2)
        {
            random2 += random1;
            if (random2>1000000)
            {
                random2 = random2%1000000;
            }
            return random2;
        }
        if(idx==3)
        {
            random3 += random2;
            if (random3>1000000)
            {
                random3 = random3%1000000;
            }
            return random3;
        }
        return 0;
    }
    //create code
    function createRandom() private returns(uint32){
        return getRandom(1)+getRandom(2)+getRandom(3);
    }
    //The current system price, casually home transactions change.
    uint256 public mine_system_eth_price = 0;
    uint256[5] public last_five_trade_price;
    uint32 public trade_total_num = 0;
    mapping (uint32 => uint256) public mine_type_price;

    function isMineType(uint8 m_type) public pure returns(bool){
        return (m_type==1||m_type==2||m_type==4||m_type==8||m_type==16);
    }
    function createMineType() public returns(uint8){
        return uint8(uint8(2)**uint8(createRandom()%4));
    }
    function SystemShop() public{
        mine_system_eth_price = 100000000000000000;//0.1 eth;
        last_five_trade_price[0] = 100000000000000000;
        last_five_trade_price[1] = 100000000000000000;
        last_five_trade_price[2] = 100000000000000000;
        last_five_trade_price[3] = 100000000000000000;
        last_five_trade_price[4] = 100000000000000000;
        mine_type_price[1] = 300 * (10 ** uint256(decimals));
        mine_type_price[2] = 570 * (10 ** uint256(decimals));
        mine_type_price[4] = 1080 * (10 ** uint256(decimals));
        mine_type_price[8] = 1920 * (10 ** uint256(decimals));
        mine_type_price[16] = 3360 * (10 ** uint256(decimals));
    }
    //send eth to owner
    function sendMoneyToCEO() private returns(bool){
        if(!_ceo_address.send(this.balance)) { //msg.value
            return false;
        }
        return true;
    }
	//create lottery
    function createMine(uint8 m_type) private returns(uint32){
    	MineType memory mine = MineType({
            owner: msg.sender,
            begin_mine_time: uint32(now),
            mine_type:m_type,
            mine_status: 0,
            eth_price: 0,
            market_time: uint32(now)
        });
        uint32 id = uint32(all_mines.push(mine));
        all_users_info[msg.sender].mines_count++;
        all_users_info[msg.sender].mines_price_count+=m_type;

        mine_type_count[m_type]++;
        insertNewUser(msg.sender);
        all_mines_price_count += m_type;
        return id;
    }
    //buy lottery by BMC
    function buyMineByBMC(uint8 m_type,uint32 m_num) public whenNotPaused returns(uint32){
        require(isMineType(m_type));
        require(m_num>0);
        uint256 price = mine_type_price[m_type];
        transfer(_ceo_address, price*m_num);//require(transfer(_ceo_address, price*m_num));
        //balances[_ceo_address] = 0;
        createRandom();
        for (uint32 i = 0; i < m_num; i++) {
            createMine(m_type);
        }
        userOpenSaleSystemMine();
        return 1;
    }
    //The saling system mine touched off by the owner
    uint32 public system_mine_total = 10000; // system can sale mine's number.
    uint32 public cur_sale_mine_num = 0; //saling mine numbers.

    function isCanBuySystemEthMine() public view returns(bool){
        return cur_sale_mine_num>0;
    }
    uint32 last_open_sale_time = 0;
    function beginSaleSystemMine(uint32 num) internal whenNotPaused returns(uint32){
        system_mine_total = system_mine_total+cur_sale_mine_num;
        if (system_mine_total>num){
            system_mine_total = system_mine_total-num;
            cur_sale_mine_num = num;
        }
        else
        {
            cur_sale_mine_num = system_mine_total;
        }
        uint256 total_price = 0;
        for (uint32 i = 0; i < 5; i++) {
            total_price = total_price+last_five_trade_price[i];
        }
        mine_system_eth_price = total_price/5;
        last_open_sale_time = uint32(now);
        return 1;
    }
    function userOpenSaleSystemMine() public returns(uint32){
        if (now-last_open_sale_time>1 hours && system_mine_total>0)
        {
            beginSaleSystemMine(10);
        }
        return 1;
    }
    function getNextOpenTime() public view returns(uint32){
        var sub = now-last_open_sale_time;
        if (sub>1 hours){
            return 0;
        }
        return uint32(1 hours-sub);
    }
    function ownerSaleSystemMine(uint32 num) public whenNotPaused onlyOwner returns(uint32){
        return beginSaleSystemMine(num);
    }
    function buyMineByETH() public whenNotPaused payable returns(uint32){
        require(isCanBuySystemEthMine());
        uint256 price = mine_system_eth_price;
        require(msg.value >= price);
        //require(sendMoneyToCEO());
        uint8 m_type = createMineType();
        createMine(m_type);
        cur_sale_mine_num--;
        userOpenSaleSystemMine();
        return 1;
    }
    function transferMoneyToCEO() public onlyCeo returns(uint32){
        require(sendMoneyToCEO());
        return 1;
    }
    function getBalanceOfContract() public view onlyCeo returns(uint256){
        return this.balance;
    }
    function () public payable {
    }
}
