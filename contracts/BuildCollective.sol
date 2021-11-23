pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {

  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  mapping(address => User) private users;

  event UserSignedUp(address indexed userAddress, User indexed user);

  function getUser(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, 0, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  struct Enterprise {
    string name;
    string owner;
    uint256 balance;
    bool registered;
  }

  mapping(address => Enterprise) private enterprises;

  mapping(address => mapping(address => User)) private members;

  event EnterpriseSignedUp(address indexed enterpriseAddress, Enterprise indexed enterprise);

  function enterpriseSignUp(string memory enterpriseName) public returns(Enterprise memory){
    require(bytes(enterpriseName).length > 0);
    require(bytes(users[msg.sender].username).length > 0);
    enterprises[msg.sender] = Enterprise(enterpriseName, users[msg.sender].username, 0, true);
    emit EnterpriseSignedUp(msg.sender, enterprises[msg.sender]);
  }

  function getEnterprise(address enterpriseAddress) public view returns (Enterprise memory) {
    return enterprises[enterpriseAddress];
  }


  function addMember(string memory toBeMember, address toBeMemberAddress) public returns(User memory){
    require(bytes(enterprises[msg.sender].name).length >0);
    require(users[toBeMemberAddress].registered);
    members[msg.sender][toBeMemberAddress]= User(toBeMember, 0, true);
  }

  function getMember(address member) public returns (User memory){
      return members[msg.sender][member];
  }


  struct Project {
    string name;
    uint256 balance;
    string owner;
    bool ownedByEnterprise;
    string LastGitCommit;
  }

  function memcmp(bytes memory a, bytes memory b) internal pure returns(bool){
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
  
  function strcmp(string memory a, string memory b) internal pure returns(bool){
        return memcmp(bytes(a), bytes(b));
  }

  mapping(address => Project) public projects; 
  mapping(address => mapping(address => User)) public contributors;

  function addNewProject(string memory projectName, string memory Link, address projectAddress) public returns(Project memory){
    require(users[msg.sender].registered);
    projects[projectAddress]= Project(projectName, 0, users[msg.sender].username, true, Link);
    return projects[projectAddress];
  }

  function getProject(address projectAddress) public returns (Project memory){
    return projects[projectAddress];
  }

  function contribute(string memory projectName, address projectAddress, string memory commit) public returns (User memory){
    assert(strcmp(projectName, projects[projectAddress].name));
    require(bytes(users[msg.sender].username).length > 0);
    contributors[projectAddress][msg.sender]= User(users[msg.sender].username, 0, true);
    projects[projectAddress].LastGitCommit = commit;
  }

  function donateToProject(string calldata projectName, address payable projectAddress, uint256 amount) external payable {
    assert(strcmp(projectName, projects[projectAddress].name));
    require(bytes(users[msg.sender].username).length> 0);
    projects[projectAddress].balance  += amount;
  } 

  function retrieveEth(address payable projectAddress, uint256 amount) external payable{
    require(bytes(users[msg.sender].username).length > 0);
    require(bytes(projects[projectAddress].name).length > 0);
    require(projects[projectAddress].balance > amount); 
    assert(strcmp(users[msg.sender].username, contributors[projectAddress][msg.sender].username));
    contributors[projectAddress][msg.sender].balance += amount;
    projects[projectAddress].balance -= amount;
  }

  struct Bounty {
    string bug;
    uint256 reward;
    bool fixedbug;
  }
 
  mapping(address => Bounty) public bounties;  

  function setBounty(string memory bugname, address projectAddress, uint256 reward) public returns(Bounty memory){
    require(strcmp(users[msg.sender].username, projects[projectAddress].owner));
    require(bytes(projects[projectAddress].name).length > 0);
    bounties[projectAddress] = Bounty(bugname, reward, false);
  }

  function fixBug(address projectAddress, string memory fixCommit) public returns (bool){
    require(bytes(users[msg.sender].username).length > 0);
    require(strcmp(users[msg.sender].username, contributors[projectAddress][msg.sender].username));
    contribute(projects[projectAddress].name, projectAddress, fixCommit);
  }

  function validateFix(address payable fixuser, address payable projectAddress, string calldata bugname) external payable {
    require(strcmp(users[msg.sender].username, projects[projectAddress].owner));
    require(strcmp(users[fixuser].username, contributors[projectAddress][fixuser].username));
    
        bounties[projectAddress].fixedbug = true;
        users[fixuser].balance += bounties[projectAddress].reward;
        bounties[projectAddress].reward = 0;
  }
      
}
