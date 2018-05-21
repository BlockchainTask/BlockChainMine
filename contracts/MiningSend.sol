pragma solidity ^0.4.18;

import "./MiningMarket.sol";

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
