## tatto smart contract

간단하게 구현하기 위해 자체 collection 기능 제거

hash를 keep하는 이유는 같은 hash로 민팅을 방지하기 위해서 = 동일한 ipfs hash로 민팅을 하면 안되므로

back을 거치지 않고 마음대로 거래를 하면 안되므로 랜덤값과 모든 거래에 대한 정보를 담은 hash를 keep 해놓고 중복시 revert한다.

기본적으로 lazyminting을 지원

백에서 모든 거래에 대해서 event listening을 하고 있을 수 없으니 서명은 무조건 백이 하는걸로 해서 불필요한 리소스 낭비를 방지한다.

### Role

admin, market, back 의 각 role을 관리하기 위한 contarct

### Market

buyLazyNFT
buyer가 signer
buyer한테 바로 민팅을 해주는 방식으로 트랜잭션 최소화 = seller(creator)는 자신이 소유한 적이 없게됨

buyNFT
buyer가 signer

거래 수수료 : 2퍼

### collection

create할때 creator가 signer, 추후에 민팅/거래시 검증

### test

모든 error 케이스에 대한 엄격한 test를 함

## Quick setup

### Installation

```
  npm install
```

### Compile Contract

```
  npx hardhat compile
```

### Test

```
  npm run test
```

### Test with gas report

```
  npm run test:gas
```

### .env

## deploy setting (goerli test network)

### notice

- Make sure to write down the address separately
- After checking in etherscan, proceed with the next deployment
- network setting in hardhat.config.ts

1. add ADMIN_ADDRESS to .env
2. npm run deploy scripts/TattoRole.deploy.ts
3. add ROLE_ADDRESS to .env
4. npm run deploy scripts/TattoCurrency.deploy.ts
5. add CURRENCY_ADDRESS to .env
6. npm run deploy scripts/TattoMarket.deploy.ts
7. npm run deploy scripts/TattoCollection.deploy.ts

## deploy address

admin address : "0xE976893Bf88F6CC81ae942cE9531fBebd8530D81"
TattoRole address : "0x94476c2E4813490404D79056B8127104e2Fa00ad"
TattoCurrency address : "0xA9fe913C2B58Ecb979382212c2DaB05012163153"
TattoMarket address : 0x63A339D0C4a1fE38abBB182F778d04CD30087330
TattoCollection address : "0x26ABac55dE5cED6608E742aed540215dCb576301"
