const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SafeClub", function () {
  async function deployFixture() {
    // Get signers
    const [owner, m1, m2, m3, recipient, outsider] = await ethers.getSigners();

    // Deploy contract with 3 initial members
    const SafeClub = await ethers.getContractFactory("SafeClub");
    const club = await SafeClub.deploy([m1.address, m2.address, m3.address]);

    // Check if waitForDeployment is available (ethers v6), fallback to deployed() if older
    if (club.waitForDeployment) {
      await club.waitForDeployment();
    } else {
      await club.deployed();
    }

    return { club, owner, m1, m2, m3, recipient, outsider };
  }

  describe("Core Flow", function () {
    it("should allow deposit -> proposal -> voting -> execution", async function () {
      const { club, m1, m2, m3, recipient } = await deployFixture();

      // 1. Deposit
      const depositAmount = ethers.parseEther("5");
      await club.connect(m1).deposit({ value: depositAmount });
      expect(await club.vaultBalance()).to.equal(depositAmount);

      // 2. Create Proposal
      const proposalAmount = ethers.parseEther("1");
      const duration = 60; // seconds

      await club.connect(m1).createProposal(
        proposalAmount,
        recipient.address,
        "Buy fancy coffee",
        duration
      );

      expect(await club.proposalCount()).to.equal(1);
      const p = await club.getProposal(0);
      expect(p.description).to.equal("Buy fancy coffee");

      // 3. Vote
      // Majority of 3 is 2.
      await club.connect(m1).vote(0, true);
      await club.connect(m2).vote(0, true);

      // 4. Time travel past deadline
      await ethers.provider.send("evm_increaseTime", [duration + 10]);
      await ethers.provider.send("evm_mine", []);

      // 5. Execute
      const recipientBalanceBefore = await ethers.provider.getBalance(recipient.address);

      await club.connect(m1).execute(0);

      const recipientBalanceAfter = await ethers.provider.getBalance(recipient.address);
      expect(recipientBalanceAfter - recipientBalanceBefore).to.equal(proposalAmount);

      // Verify executed state
      const pAfter = await club.getProposal(0);
      expect(pAfter.executed).to.equal(true);
    });
  });

  describe("Validation", function () {
    it("should prevent double voting", async function () {
      const { club, m1, recipient } = await deployFixture();

      await club.connect(m1).deposit({ value: ethers.parseEther("1") });
      await club.connect(m1).createProposal(ethers.parseEther("0.1"), recipient.address, "X", 60);

      await club.connect(m1).vote(0, true);

      await expect(
        club.connect(m1).vote(0, false)
      ).to.be.revertedWith("Already voted");
    });

    it("should prevent execution before deadline", async function () {
      const { club, m1, m2, recipient } = await deployFixture();

      await club.connect(m1).deposit({ value: ethers.parseEther("1") });
      await club.connect(m1).createProposal(ethers.parseEther("0.1"), recipient.address, "X", 60);

      await club.connect(m1).vote(0, true);
      await club.connect(m2).vote(0, true);

      // Try to execute immediately
      await expect(
        club.connect(m1).execute(0)
      ).to.be.revertedWith("Too early");
    });
  });
});
