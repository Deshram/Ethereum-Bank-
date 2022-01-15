pragma solidity >=0.7.0 <0.9.0;

//using function from ceth contract 
interface cETH{
    
    //functions regarding deposit and withdrawal
    function mint() external payable;
    function redeem(uint redeemTokens) external returns (uint);

    //functions regarding balance and exchange rate
    function balanceOf(address owner) external view returns (uint256 balance);
    function exchangeRateStored() external view returns (uint);

}

contract SmartBankContract {
    
    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;  //ceth token contract address on ropsten network
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    mapping (address => uint) balances;

    //fallback function to transfer token from contract to address
    receive() external payable {
    } 

    function addBalance() public payable{
        uint cethBeforeMinting = ceth.balanceOf(address(this));
        ceth.mint{value: msg.value}();
        uint amountofCeth = ceth.balanceOf(address(this)) - cethBeforeMinting;
        balances[msg.sender] += amountofCeth;
    }

    //get eth balance deposited by user
    function getBalance(address accountAddress) public view returns(uint){
        return balances[accountAddress] * ceth.exchangeRateStored() / 1e18;
    }

    //get ceth balance deposited by user
    function getCethBalance() public view returns(uint){
        return balances[msg.sender];
    }

    //withdraw function that takes amount in wei 
    function withdraw(uint amount) public payable {
        require(amount <= getBalance(msg.sender));    
        uint redeemToken =  amount / (ceth.exchangeRateStored() / 1e18);
        ceth.redeem(redeemToken);
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= redeemToken;
    }
    
    //total eth flowed through this contract 
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
}




