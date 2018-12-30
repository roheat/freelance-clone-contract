pragma solidity ^0.5.2;

contract Project {
    struct Proposal {
        address payable name;
        uint rate;
        bool hired;
    }
    
    Proposal[] public proposals;
    string public title;
    string public description;
    uint public budget;
    address payable public manager;
    mapping (address => bool) public freelancers;
    uint public freelancerCount;
    enum Status {Open, Hired, Complete}
    Status public status;
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    constructor(string memory _title, string memory _description) public payable {
        manager = msg.sender;
        title = _title;
        description = _description;
        budget = msg.value;
        status = Status.Open;
    }
    
    function _apply(uint _proposal) public {
        require(!freelancers[msg.sender]);
        require(_proposal <= budget);
        freelancers[msg.sender] = true;
        freelancerCount++;
        Proposal memory newProposal = Proposal({
           name: msg.sender,
           rate: _proposal,
           hired: false
        });
        proposals.push(newProposal);
    }
    
    function hire(uint index) public restricted {
        require(!proposals[index].hired);
        require(status == Status.Open);
        proposals[index].hired = true;
        status = Status.Hired;
    }
    
    function pay(uint index) public restricted {
        Proposal storage currProposal = proposals[index];
        require(status == Status.Hired);
        require(currProposal.hired);
        require(status != Status.Complete);
        status = Status.Complete;
        currProposal.name.transfer(currProposal.rate);
        manager.transfer(budget - currProposal.rate);
    }
}