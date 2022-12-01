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
TattoRole address : "0xc3ca39a5673676F67a3Df75c7C496EC8B7487648"
TattoCurrency address : "0x5eDaeBeAd6Ed654F95949120D23B50D20829358A"
TattoMarket address : 0xb97cCDFE4d7503FA038509aeE432747bbdD2bb00
TattoCollection address : "0xe4F0E339c173EDb993bAe6f85DC1dcfc9EBbe810"
