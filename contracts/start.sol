pragma solidity ^0.4.18;
  
contract SpriteTower {

  address public intermediary;  // 仲介
  address public seller;        // 賣方

  bool public refunded;         // 是否已交付保證金
  bool public complete;         // 是否已完成交易
  bool public isLegal;          // 是否合法
  bool public isRecognizance;   // 是否給予保證金
  uint public numPledges;

  struct Pledge {               // 使用權狀-合約資料
    uint num;                   // 編號
    address buyer;              // 買方
    bytes32 message;             // 相關訊息
  }
  
  mapping(uint => Pledge) public pledges;

  // constructor 建構式-初始化合約
  function SpriteTower(address _seller) {
    intermediary = msg.sender;
    numPledges = 0;
    refunded = false;
    complete = false;
    seller = _seller;
  }

  // add a new pledge 新合約
  function pledge(bytes32 _message) public returns(bool complete) {
    if (msg.value == 0 || complete || refunded) return false;
    pledges[numPledges] = Pledge(msg.value, msg.sender, _message);
    numPledges++;
  }

  // 取得合約當前金額
  function getPot() constant returns (uint) {
    return this.balance;
  }

  // 塔位交易出現問題時的退款處理
  function refund() public returns(bool complete) {
    if (msg.sender != intermediary || complete || refunded)  return false;
    for (uint i = 0; i < numPledges; ++i) {
      pledges[i].buyer.send(pledges[i].num);
    }
    refunded = true;
    complete = true;
  }

  // 交易完成時 將金額移交給賣家與仲介
  function giveSalecoin() public returns(bool complete) {
    if (msg.sender != intermediary || complete || refunded)  return false;
    seller.send(this.balance);
    complete = true;
  }

  // 檢查合約項目
  function checkData() public returns(bool complete) {
    if ( isLegal || isRecognizance || complete)  return false;
    seller.send(this.balance);
    complete = true;
  }
}