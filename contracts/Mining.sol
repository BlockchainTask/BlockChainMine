pragma solidity ^0.4.18;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
    // Public variables of the token
    string public name = "BitCoinMine";
    string public symbol = "BCM";
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply = 21000000 * (10 ** uint256(decimals));

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);


    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}

//pragma solidity ^0.4.18;

//import "zeppelin-solidity/contracts/token/StandardToken.sol";
//import "./TokenERC20.sol";


contract BitMineCoin is TokenERC20{
    address public _owner;
    address public _mine_pool_locked_address;

    function BitMineCoin() public{
        _mine_pool_locked_address = address(100);
        _owner = msg.sender;
        //locked to an empty address, no one can control.
        balanceOf[_mine_pool_locked_address] = totalSupply-2100000*(10 ** uint256(decimals)); 
        //use to reward to active players in early period.
        balanceOf[_owner] = 2100000*(10 ** uint256(decimals)); 
    }
}


//pragma solidity ^0.4.18;

//import "./BitMineCoin.sol";

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


//pragma solidity ^0.4.18;

//import "./MiningBase.sol";

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

//pragma solidity ^0.4.18;

//import "./SystemShop.sol";

contract MiningMarket is SystemShop{
    function saleMarketMine(uint32 mine_id,uint256 price) public whenNotPaused returns(uint32){
        require(mine_id<all_mines.length);
        require(all_mines[mine_id].owner==msg.sender);
        if (all_mines[mine_id].mine_status==0)
        {
            saling_mine_type_count[0]++;
            saling_mine_type_count[all_mines[mine_id].mine_type]++;
            all_users_info[msg.sender].sale_mines_count++;
        }
        all_mines[mine_id].market_time = uint32(now);
        all_mines[mine_id].eth_price = price;
        all_mines[mine_id].mine_status = 1;
        return 1;
    }
    function undoSaleMarketMine(uint32 mine_id) public whenNotPaused returns(uint32){
        require(mine_id<all_mines.length);
        require(all_mines[mine_id].owner==msg.sender);
        if (all_mines[mine_id].mine_status==1)
        {
            saling_mine_type_count[0]--;
            saling_mine_type_count[all_mines[mine_id].mine_type]--;
            all_users_info[msg.sender].sale_mines_count--;
        }
        all_mines[mine_id].mine_status = 0;
        return 1;
    }
    function buyMarketMine(uint32 mine_id) public whenNotPaused payable returns(uint32){
        require(mine_id<all_mines.length);
        require(all_mines[mine_id].mine_status==1);
        require(all_mines[mine_id].owner!=msg.sender);
        require(msg.value>=all_mines[mine_id].eth_price);

        require(all_mines[mine_id].owner.send(all_mines[mine_id].eth_price*95/100));  //msg.value 5% Fee
        //record trade number and price
        last_five_trade_price[trade_total_num%5] = all_mines[mine_id].eth_price;
        trade_total_num++;

        //record saler mined coins
        uint32 sub_time = uint32(now-all_mines[mine_id].begin_mine_time);
        if (sub_time/10 minutes>0)
        {
            AfterSaleEarnCoinRecord memory record = AfterSaleEarnCoinRecord({
                owner: all_mines[mine_id].owner,
                earn_times: sub_time/10 minutes,
                mine_type:all_mines[mine_id].mine_type
            });
            sale_earn_records.push(record);
        }
        all_users_info[msg.sender].mines_count++;
        all_users_info[msg.sender].mines_price_count += all_mines[mine_id].mine_type;

        all_users_info[all_mines[mine_id].owner].mines_count--;
        all_users_info[all_mines[mine_id].owner].mines_price_count -= all_mines[mine_id].mine_type;
        saling_mine_type_count[0]--;
        saling_mine_type_count[all_mines[mine_id].mine_type]--;
        all_users_info[all_mines[mine_id].owner].sale_mines_count--;

        all_mines[mine_id].owner = msg.sender;
        all_mines[mine_id].begin_mine_time = uint32(now);
        all_mines[mine_id].mine_status = 0;
        insertNewUser(msg.sender);
        userOpenSaleSystemMine();
        return 1;
    }

    function getSelfMines(uint32 page,uint32 page_count) public constant returns(uint32[] memory r_ids) {
        uint32 num = all_users_info[msg.sender].mines_count;
        if (page*page_count>num)
        {
            return;
        }
        uint32[] memory ids = new uint32[](num);
        uint32 idx = 0;
        uint32 i = 0;
        uint32 n = 0;
        for (i = 0; i < all_mines.length; i++) {
            if (all_mines[i].owner==msg.sender)
            {
                ids[idx++] = i;
            }
            if(idx>=num){
                break;
            }
        }
        idx = 0;
        for (i=0;i<num-1;i++)
        {
            MineType storage mine1 = all_mines[ids[i]];
            for (n=i+1;n<num;n++)
            {
                MineType storage mine2 = all_mines[ids[n]];
                if (mine2.mine_type<mine1.mine_type)
                {
                    idx = ids[i];
                    ids[i] = ids[n];
                    ids[n] = idx;
                }
            }
        }
        
        uint32 r_num = page_count;
        if (num-page_count*page<page_count)
        {
            r_num = num-page_count*page;
        }
        r_ids = new uint32[](r_num);
        for (i=0;i<r_num;i++){
            r_ids[i] = ids[page*page_count+i];
        }
        
    }
    function getSalingMines(uint8 m_type,uint8 page,uint32 page_count) public constant returns(uint32[] memory r_ids) 
    {
        uint32 num = saling_mine_type_count[m_type];
        if (page*page_count>num)
        {
            return;
        }
        uint32[] memory ids = new uint32[](num);
        uint32 idx = 0;
        uint32 m = 0;
        uint32 n = 0;
        for (m = 0; m < all_mines.length; m++) {
            if ((m_type==0 &&all_mines[m].mine_status==1) || (all_mines[m].mine_status==1 && all_mines[m].mine_type==m_type))
            {
                ids[idx++] = m;
            }
            if(idx>=num){
                break;
            }
        }
        idx = 0;
        for (m=0;m<num-1;m++)
        {
            MineType storage mine1 = all_mines[ids[m]];
            for (n=m+1;n<num;n++)
            {
                MineType storage mine2 = all_mines[ids[n]];
                if (mine2.eth_price<mine1.eth_price)
                {
                    idx = ids[m];
                    ids[m] = ids[n];
                    ids[n] = idx;
                }
            }
        }
        uint32 r_num = page_count;
        if (num-page_count*page<page_count)
        {
            r_num = num-page_count*page;
        }
        r_ids = new uint32[](r_num);
        for (uint32 x=0;x<r_num;x++){
            r_ids[x] = ids[page*page_count+x];
        }
    }

    //reimburse holder of mines, params num is type 1 mine reimburse amount
    function reimburseUsers(uint256 amount) public onlyCeo returns(uint32){
        for (uint32 j = 0; j < all_mines.length; j++) 
        {
            transfer(all_mines[j].owner, all_mines[j].mine_type*amount);
        }
    }
}

//pragma solidity ^0.4.18;

//import "./MiningMarket.sol";

contract MiningSend is MiningMarket{
    //number of mining days
    uint32 public cur_day_num = 1;

    /*
    //days of every peroid
    uint32 public days_one_peroid = 146;

    function getCurRuningPeroid() public view returns(uint32){
        uint32 cur_peroid = cur_day_num/days_one_peroid;
        if (days_one_peroid*cur_peroid==cur_day_num) {
            return cur_peroid;
        }
        return cur_peroid+1;
    }
    function getCoinsOfOneDay() public view returns(uint256){
        uint256 coins = totalSupply;
        for (uint32 i = 0; i < getCurRuningPeroid(); i++) {
            coins = coins/2;
        }
        return coins/days_one_peroid;
    }
    */
    function getTenMinCoins() public view returns(uint256){
        uint256 coins = totalSupply;
        uint32 num = 10;
        for (uint32 i =0;i<10;i++)
        {
            coins = coins/2;
            if (balanceOf[_mine_pool_locked_address]>coins)
            {
                num = i;
                break;
            }
        }
        uint256 r_coin = 30*(10**18);
        for(uint j=0;j<num;j++)
        {
            r_coin = r_coin/2;
        }
        return r_coin/144;
    }
    function getTenMinEstimateCoins() public view returns(uint256){
        return getTenMinCoins();
        //mine_type_count[1]+mine_type_count[2]*2+mine_type_count[4]*4+mine_type_count[8]*8+mine_type_count[16]*16;
        //uint256 ten_mins_of_one_day = 1 days / 10 minutes;
        //return getCoinsOfOneDay()/(all_mines_price_count*ten_mins_of_one_day);
    }
    /*
    function getTenMinCounts() public view returns(uint256){
        uint256 ten_min_num = 0;
        for (uint32 i=0;i<sale_earn_records.length;i++)
        {
            ten_min_num += sale_earn_records[i].earn_times*sale_earn_records[i].mine_type;
        }
        for (uint32 j=0;j<all_mines.length;j++)
        {   
            ten_min_num += ((now-all_mines[j].begin_mine_time)/ 10 minutes)*all_mines[j].mine_type;
        }
        return ten_min_num;
    }
    function getTenMinCoins() public view returns(uint256){
        return getTenMinCoins();
        //uint256 ten_min_num = getTenMinCounts();
        //uint256 day_coins = getCoinsOfOneDay();
        //return day_coins/ten_min_num;
    }
    */
    //send mined coin
    function sendMinedCoin() public onlyOwner whenNotPaused {
        //delete yestoday_earn_coin;
        uint32 m = 0;
        for (m=0;m<all_users_address.length;m++)
        {
            all_users_info[all_users_address[m]].yestoday_earn_coin=0;
        }
        uint256 ten_coin = getTenMinCoins();
        uint256 tmp_coins = 0;
        for (uint32 i=0;i<sale_earn_records.length;i++)
        {
            tmp_coins = sale_earn_records[i].earn_times*sale_earn_records[i].mine_type*ten_coin;
            if (tmp_coins>0)
            {
                
                all_users_info[sale_earn_records[i].owner].yestoday_earn_coin+=tmp_coins;
                all_users_info[sale_earn_records[i].owner].all_earn_coin+=tmp_coins;
            }
            
        }
        for (uint32 j=0;j<all_mines.length;j++)
        {   
            tmp_coins = ((now-all_mines[j].begin_mine_time)/ 10 minutes)*all_mines[j].mine_type*ten_coin;
            all_users_info[all_mines[j].owner].yestoday_earn_coin+=tmp_coins;
            all_users_info[all_mines[j].owner].all_earn_coin+=tmp_coins;
            all_mines[j].begin_mine_time = uint32(now);
        }
        //send today_earn_coin;
        m = 0;
        for (m=0;m<all_users_address.length;m++)
        {
            _transfer(_mine_pool_locked_address,all_users_address[m], all_users_info[all_users_address[m]].yestoday_earn_coin);
        }
        cur_day_num += 1;
        sale_earn_records.length = 0;
    }
    /*
    function getRankMineUsers() public view returns(uint32[] memory ids){
        uint32 num = uint32(all_users_address.length);
        uint32[] memory tmp_users = new uint32[](num);
        for (uint32 i=0;i<num;i++){
            tmp_users[i] = i;
        }
        uint32 exchange_idx = 0;
        for (uint32 m=0;m<num-1;m++)
        {
            UserInfo storage user1 = all_users_info[all_users_address[tmp_users[m]]];
            for (uint32 n=m+1;n<num;n++)
            {
                UserInfo storage user2 = all_users_info[all_users_address[tmp_users[n]]];
                if (user2.all_earn_coin>user1.all_earn_coin)
                {
                    exchange_idx = tmp_users[m];
                    tmp_users[m] = tmp_users[n];
                    tmp_users[n] = exchange_idx;
                }
            }
        }
        uint32 r_num = 100;
        if (num<100){
            r_num = num;
        }
        ids = new uint32[](r_num);
        for (uint32 j=0;j<r_num;j++){
            ids[j] = tmp_users[j];
        }
    }
    */

    function getRankPriceUsers(address user) public view returns(uint32[] memory ids,uint32 myrank){
        uint32 num = uint32(all_users_address.length);
        uint32[] memory tmp_users = new uint32[](num);
        for (uint32 i=0;i<num;i++){
            tmp_users[i] = i;
        }
        uint256 price1 = 0;
        uint256 price2 = 0;
        uint256 one_price = 300*(10**uint256(decimals));
        uint32 exchange_idx = 0;
        uint32 m = 0;
        for (m=0;m<num-1;m++)
        {
            UserInfo storage user1 = all_users_info[all_users_address[tmp_users[m]]];
            price1 = user1.mines_price_count*one_price+balanceOf[all_users_address[tmp_users[m]]];
            for (uint32 n=m+1;n<num;n++)
            {
                UserInfo storage user2 = all_users_info[all_users_address[tmp_users[n]]];
                price2 = user2.mines_price_count*one_price+balanceOf[all_users_address[tmp_users[n]]];
                if (price2>price1)
                {
                    exchange_idx = tmp_users[m];
                    tmp_users[m] = tmp_users[n];
                    tmp_users[n] = exchange_idx;
                }
            }
        }
        myrank = 0;
        m = 0;
        for (m=0;m<num;m++)
        {
            if (user==all_users_address[tmp_users[m]]){
                myrank = m+1;
                break;
            }
        }
        uint32 r_num = 100;
        if (num<100){
            r_num = num;
        }
        ids = new uint32[](r_num);
        m = 0;
        for (m=0;m<r_num;m++){
            ids[m] = tmp_users[m];
        }
    }
    
}

