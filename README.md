## blockend

간단하게 구현하기 위해 자체 collection 기능 제거

hash를 keep하는 이유는 같은 hash로 민팅을 방지하기 위해서 = 동일한 ipfs hash로 민팅을 하면 안되므로

기본적으로 lazyminting을 지원

### Market

buyLazyNFT
buyer가 signer
buyer한테 바로 민팅을 해주는 방식으로 트랜잭션 최소화 = seller(creator)는 자신이 소유한 적이 없게됨

buyNFT
buyer가 signer

거래 수수료 : 2퍼

### collection

create할때 creator가 signer, 추후에 민팅/거래시 검증

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
