pragma solidity 0.7.5;

import "./Ownable.sol";

import "./Destroyable.sol";

interface GovernmentInterface{
    function addTransaction(address _from, address _to, uint _amount) external payable ;
}

contract BANK is Ownable, Destroyable {
    
    GovernmentInterface governmentInstance = GovernmentInterface(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
    
    mapping(address => uint) balance;
    
    event depositDone( uint amount, address indexed depositedTo);
    
    function deposit() public payable returns (uint) {
        balance[msg.sender] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return balance[msg.sender];
    }
    
   function withdraw(uint amount) public onlyOwner returns (uint) {
        require(balance[msg.sender] >= amount);
        balance[msg.sender] -= amount;
        msg.sender.transfer(amount);
        return balance[msg.sender];
    }
    
    function getBalance() public view returns (uint){
        return balance[msg.sender];
    }
    
    function transfer(address recipient, uint amount) public {
        require(balance[msg.sender] >= amount, "Balance not sufficient");
        require(msg.sender != recipient, "Do not transfer to yourself");
        
        uint previousSenderBalance = balance[msg.sender];
        
        _transfer(msg.sender, recipient, amount);
        
        governmentInstance.addTransaction{value: 1 ether}(msg.sender, recipient, amount);
        
        assert(balance[msg.sender] == previousSenderBalance - amount);
    }
    
    function _transfer(address from, address to, uint amount) private {
        balance[from] -= amount;
        balance[to] += amount;
    }
}
