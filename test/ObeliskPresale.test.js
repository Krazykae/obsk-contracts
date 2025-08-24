const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ObeliskPresale", function () {
  let obeliskToken, presale, owner, buyer1, buyer2;
  let usdc;

  beforeEach(async function () {
    [owner, buyer1, buyer2] = await ethers.getSigners();

    // Deploy OBSK token
    const ObeliskToken = await ethers.getContractFactory("OBLSK");
    obeliskToken = await ObeliskToken.deploy();

    // Deploy mock USDC (for testing)
    const MockUSDC = await ethers.getContractFactory("OBLSK"); // Using same ERC20 for simplicity
    usdc = await MockUSDC.deploy();

    // Deploy presale contract
    const ObeliskPresale = await ethers.getContractFactory("ObeliskPresale");
    presale = await ObeliskPresale.deploy(obeliskToken.address, usdc.address);

    // Transfer tokens to presale contract
    await obeliskToken.transfer(presale.address, ethers.utils.parseEther("50000000"));
  });

  describe("Presale Functionality", function () {
    it("Should allow ETH purchases", async function () {
      const ethAmount = ethers.utils.parseEther("1");
      await presale.connect(buyer1).buyWithETH({ value: ethAmount });
      
      const contribution = await presale.contributions(buyer1.address);
      expect(contribution).to.equal(ethAmount);
    });

    it("Should apply early bird bonus correctly", async function () {
      const ethAmount = ethers.utils.parseEther("1");
      await presale.connect(buyer1).buyWithETH({ value: ethAmount });
      
      const tokensPurchased = await presale.tokensPurchased(buyer1.address);
      // Should get 20% bonus for early bird
      const expectedTokens = ethAmount.div(ethers.utils.parseEther("0.01")).mul(120).div(100);
      expect(tokensPurchased).to.be.closeTo(expectedTokens, ethers.utils.parseEther("1"));
    });

    it("Should track total raised correctly", async function () {
      const ethAmount = ethers.utils.parseEther("2");
      await presale.connect(buyer1).buyWithETH({ value: ethAmount });
      
      const totalRaised = await presale.totalRaised();
      expect(totalRaised).to.equal(ethAmount);
    });

    it("Should prevent purchases when presale is inactive", async function () {
      await presale.endPresale();
      
      await expect(
        presale.connect(buyer1).buyWithETH({ value: ethers.utils.parseEther("1") })
      ).to.be.revertedWith("Presale not active");
    });

    it("Should allow owner to withdraw funds", async function () {
      const ethAmount = ethers.utils.parseEther("1");
      await presale.connect(buyer1).buyWithETH({ value: ethAmount });
      
      const initialBalance = await owner.getBalance();
      await presale.withdrawFunds();
      const finalBalance = await owner.getBalance();
      
      expect(finalBalance).to.be.gt(initialBalance);
    });
  });
});
