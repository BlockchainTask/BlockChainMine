pragma solidity ^0.4.18;

import "./SystemShop.sol";

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