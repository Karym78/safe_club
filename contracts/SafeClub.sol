// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SafeClub is Ownable, ReentrancyGuard {
    mapping(address => bool) public isMember;
    uint256 public memberCount;

    struct Proposal {
        uint256 amount;
        address payable recipient;
        string description;
        uint256 deadline;
        bool executed;
        uint256 yesVotes;
        uint256 noVotes;
    }

    Proposal[] private _proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event MemberAdded(address indexed member);
    event MemberRemoved(address indexed member);

    event Deposited(address indexed from, uint256 amount);
    event ProposalCreated(
        uint256 indexed id,
        address indexed creator,
        address indexed recipient,
        uint256 amount,
        uint256 deadline,
        string description
    );
    event Voted(uint256 indexed id, address indexed voter, bool support);
    event Executed(uint256 indexed id, address indexed recipient, uint256 amount);

    modifier onlyMember() {
        require(isMember[msg.sender], "Not a member");
        _;
    }

    constructor(address[] memory initialMembers) Ownable(msg.sender) {
        for (uint256 i = 0; i < initialMembers.length; i++) {
            _addMember(initialMembers[i]);
        }
    }

    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");
        emit Deposited(msg.sender, msg.value);
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function addMember(address member) external onlyOwner {
        _addMember(member);
    }

    function removeMember(address member) external onlyOwner {
        require(isMember[member], "Not a member");
        isMember[member] = false;
        memberCount -= 1;
        emit MemberRemoved(member);
    }

    function _addMember(address member) internal {
        require(member != address(0), "Zero address");
        require(!isMember[member], "Already member");
        isMember[member] = true;
        memberCount += 1;
        emit MemberAdded(member);
    }

    function proposalCount() external view returns (uint256) {
        return _proposals.length;
    }

    function getProposal(uint256 id) external view returns (Proposal memory) {
        require(id < _proposals.length, "Bad id");
        return _proposals[id];
    }

    function createProposal(
        uint256 amount,
        address payable recipient,
        string calldata description,
        uint256 durationSeconds
    ) external onlyMember returns (uint256 id) {
        require(recipient != address(0), "Zero recipient");
        require(amount > 0, "Zero amount");
        require(durationSeconds > 0, "Zero duration");

        uint256 deadline = block.timestamp + durationSeconds;

        _proposals.push(
            Proposal({
                amount: amount,
                recipient: recipient,
                description: description,
                deadline: deadline,
                executed: false,
                yesVotes: 0,
                noVotes: 0
            })
        );

        id = _proposals.length - 1;

        emit ProposalCreated(id, msg.sender, recipient, amount, deadline, description);
    }

    function vote(uint256 id, bool support) external onlyMember {
        require(id < _proposals.length, "Bad id");
        Proposal storage p = _proposals[id];

        require(block.timestamp < p.deadline, "Voting closed");
        require(!p.executed, "Already executed");
        require(!hasVoted[id][msg.sender], "Already voted");

        hasVoted[id][msg.sender] = true;

        if (support) {
            p.yesVotes += 1;
        } else {
            p.noVotes += 1;
        }

        emit Voted(id, msg.sender, support);
    }

    function requiredMajority() public view returns (uint256) {
        require(memberCount > 0, "No members");
        return (memberCount / 2) + 1;
    }

    function execute(uint256 id) external nonReentrant onlyMember {
        require(id < _proposals.length, "Bad id");
        Proposal storage p = _proposals[id];

        require(block.timestamp >= p.deadline, "Too early");
        require(!p.executed, "Already executed");

        uint256 majority = requiredMajority();
        require(p.yesVotes >= majority, "Not enough yes votes");
        require(p.yesVotes > p.noVotes, "Not accepted");

        require(p.amount <= address(this).balance, "Insufficient vault");

        p.executed = true;

        (bool ok, ) = p.recipient.call{value: p.amount}("");
        require(ok, "Transfer failed");

        emit Executed(id, p.recipient, p.amount);
    }
}
