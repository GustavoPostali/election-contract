pragma solidity ^0.4.21;

contract Election {
    struct Candidate {
        string name;
        uint voteCount;
    }
    
    struct Voter {
        bool authorized;
        bool voted;
        string vote;
    }
    
    address public owner;
    string public electionName;
    
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint public totalVotes;
    mapping(address => bool) public admins;
    
    
    modifier ownerOnly(){
        require(msg.sender == owner);
        _;
    }
    
    modifier adminOnly(){
        require(admins[msg.sender] == true);
        _;
    }
    
    
    function addAdmin(address _person) adminOnly public {
        admins[_person]=true;
    }
    
    function isAdmin(address _person) public view returns(bool){
        if(admins[_person]){
            return true;
        } else {
            return false;
        }
    }
    
    function Election(string _name) public {
        owner = msg.sender;
        electionName = _name;
        admins[msg.sender] = true;
    }
    
    function removeAdmin(address _person) adminOnly public {
        require(_person != owner);
        admins[_person] = false;
    }
    
    function addCandidate(string _name) adminOnly public {
        candidates.push(Candidate(_name, 0));
    }
    
    function getNumCandidate() public view returns(uint){
        return candidates.length;
    }
    
    function authorize(address _person) adminOnly public {
        voters[_person].authorized = true;
    }
    
    function vote(string _name) public returns(bool success){
        require(voters[msg.sender].authorized);
        require(!voters[msg.sender].voted);
        
        for(uint i=0;i<getNumCandidate();i++){
            if(keccak256(bytes(candidates[i].name)) == keccak256(bytes(_name))){
                voters[msg.sender].vote = _name;
                voters[msg.sender].voted = true;
                
                candidates[i].voteCount += 1;
                totalVotes += 1;
                
                return true;
            }
        }
        
        return false;
    }
    
    function getParcials(string _name) public view returns(uint parcials){
        for(uint i=0;i<getNumCandidate();i++){
            if(keccak256(bytes(candidates[i].name)) == keccak256(bytes(_name))){
                return candidates[i].voteCount;
            }
        }
        
        return 0;
    }
    
    function invalidateVoter(address _voter) adminOnly public {
        require(voters[_voter].authorized);
        
        if(voters[_voter].voted){
            for(uint i=0;i<getNumCandidate();i++){
                if(keccak256(bytes(candidates[i].name)) == keccak256(bytes(voters[_voter].vote))){
                    candidates[i].voteCount -= 1;
                }
            }
            
            voters[_voter].vote = '';
            voters[_voter].voted = false;
            totalVotes -= 1;
            
        }
        
        voters[_voter].authorized = false;
    }
    
    function end() ownerOnly public{
        selfdestruct(owner);
    }
}
