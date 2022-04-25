const NFTrade = artifacts.require("NFTrade");
const MockNFT = artifacts.require("MockNFT");
const { expectRevert, expectEvent } = require("@openzeppelin/test-helpers");

contract("NFTrade", function (accounts) {
  let nft, instance;
  before(async function () {
    nft = await MockNFT.new(accounts[0], accounts[1]);
    instance = await NFTrade.deployed();
  });
  it("reverts if address provided is not ERC-721", async function () {
    await expectRevert.unspecified(instance.createSwap(accounts[1], 1, [accounts[2], accounts[2]], [1, 2], 0));
  });
  it("emits SwapCreated event", async function () {
    const tx = await instance.createSwap(accounts[1], 1, [nft.address, nft.address], [1, 2], 0);
    await expectEvent(tx, "SwapCreated", { _id: "0", _creator: accounts[0], _recipient: accounts[1] });
  });
  it("creates valid participants array", async function () {
    expect(await instance.participants(0, 0)).to.equal(accounts[0]);
    expect(await instance.participants(0, 1)).to.equal(accounts[1]);
  });
  it("executeSwap reverts if a token is unapproved", async function () {
    await expectRevert(instance.executeSwap(0, { from: accounts[1] }), "Token not approved.");
  });
  it("tokens transferred properly after successful executeSwap", async function () {
    await nft.setApprovalForAll(instance.address, true);
    await nft.setApprovalForAll(instance.address, true, { from: accounts[1] });
    await instance.executeSwap(0, { from: accounts[1] });
    expect(await nft.ownerOf(1)).to.equal(accounts[1]);
    expect(await nft.ownerOf(2)).to.equal(accounts[0]);
  });
});
