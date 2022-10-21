## blockend

간단하게 구현하기 위해 자체 collection 기능 제거
collection 내부에서만 거래가능하도록 구현

기본적으로 lazyminting을 지원

거래 수수료 : 2퍼

TODO: 각 컨트랙트에 대한 간단한 설명

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
