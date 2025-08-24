const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ObeliskPresale", function () {
  it("Should deploy successfully", async function () {
    const [owner] = await ethers.getSigners();

    // Deploy OBSK token first
    const ObeliskToken = await ethers.getContractFactory("OBLSK");
    const obeliskToken = await ObeliskToken.deploy();

    // Deploy presale contract
    const ObeliskPresale = await ethers.getContractFactory("ObeliskPresale");
    const presale = await ObeliskPresale.deploy(obeliskToken.address, obeliskToken.address);

    expect(presale.address).to.not.equal(0);
    expect(await presale.presaleActive()).to.equal(true);
  });
});
