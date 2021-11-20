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


  function addMember(User memory toBeMember, address toBeMemberAddress) public returns(User memory){
    require(bytes(enterprises[msg.sender].name).length >0);
    require(toBeMember.registered);
    members[msg.sender][toBeMemberAddress]= toBeMember;
  }


  struct Project {
    string name;
    uint256 balance;
    string owner;
    bool ownedByEnterprise;
    string linkToGitRepo;
    string[] bug;
    uint256[] bounty;
    bool[] bugFixed;
  }

  mapping(address => Project) public projects; 
  mapping(address => mapping(address => User)) private contributors;

  function memcmp(bytes memory a, bytes memory b) internal pure returns(bool){
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
  
  function strcmp(string memory a, string memory b) internal pure returns(bool){
        return memcmp(bytes(a), bytes(b));
    }

  
  event NewProject(address indexed userAddress, Project indexed newproject);
  
  function addNewProject(string memory projectName, string memory Link) public returns(Project memory){
    require(bytes(projectName).length > 0);
    require(bytes(users[msg.sender].username).length > 0  || bytes(enterprises[msg.sender].name).length > 0 );

    if (bytes(enterprises[msg.sender].name).length > 0){
      projects[msg.sender]= Project(projectName, 0, enterprises[msg.sender].name, true, Link, new string[](0), new uint256[](0), new bool[](0));
    
    } else if(bytes(users[msg.sender].username).length > 0){
      projects[msg.sender]= Project(projectName, 0, users[msg.sender].username, true, Link, new string[](0), new uint256[](0), new bool[](0));
    }
    emit NewProject(msg.sender, projects[msg.sender]);
  }

  function contribute(string memory projectName, address projectAddress) public returns (User memory){
    assert(strcmp(projectName, projects[projectAddress].name));
    require(bytes(users[msg.sender].username).length > 0);
    contributors[projectAddress][msg.sender]= User(users[msg.sender].username, 0, true);
  }

  function donateToProject(string memory projectName, address projectAddress, uint256 amount) public returns(bool){
    assert(strcmp(projectName, projects[projectAddress].name));
    require(bytes(users[msg.sender].username).length> 0);
    projects[projectAddress].balance  += amount;
    return true;
  } 

  function retrieveEth(address projectAddress, uint256 amount) public returns (bool){
    require(bytes(users[msg.sender].username).length > 0);
    require(bytes(projects[projectAddress].name).length > 0);
    require(projects[projectAddress].balance > amount); 
    assert(strcmp(users[msg.sender].username, contributors[projectAddress][msg.sender].username));
    contributors[projectAddress][msg.sender].balance += amount;
    projects[projectAddress].balance -= amount;
  }

  function setBounty(string memory projectName, address projectAddress, uint256 amount, string memory bugName) public returns(Project memory){
    require(strcmp(users[msg.sender].username, projects[projectAddress].owner));
    require(bytes(projects[projectAddress].name).length > 0);
    (projects[projectAddress].bug).push(bugName);
    (projects[projectAddress].bounty).push(amount);
    (projects[projectAddress].bugFixed).push(false);
  }

  function fixBug(address projectAddress, string memory bugName) public returns (bool){

    require(bytes(users[msg.sender].username).length > 0);
    require(bytes(bugName).length > 0);

    uint indexOfBug;
    for (uint j=0; j<=(projects[projectAddress].bug).length;j++){
      if (strcmp(bugName, projects[projectAddress].bug[j])) {
        indexOfBug = j;
        break;
      }
      projects[projectAddress].bugFixed[indexOfBug] = true;
      users[msg.sender].balance += projects[projectAddress].bounty[indexOfBug];
    }
  }
}
