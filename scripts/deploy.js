const hre = require("hardhat");

async function main() {
    const [deployer, m1, m2] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // We use the deployer and two other test accounts as initial members
    // In a real deployment, you would replace these with actual addresses
    // e.g. ["0x...", "0x...", "0x..."]
    const initialMembers = [
        deployer.address,
        m1 ? m1.address : deployer.address,
        m2 ? m2.address : deployer.address
    ];

    const club = await hre.ethers.deployContract("SafeClub", [initialMembers]);

    await club.waitForDeployment();

    console.log("SafeClub deployed to:", await club.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
