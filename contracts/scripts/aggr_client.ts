import { Obelisk, loadMetadata, Types, Network } from '@0xobelisk/aptos-client';
import dotenv from 'dotenv';
dotenv.config();

export const delay = (ms: number) =>
  new Promise((resolve) => setTimeout(resolve, ms));

async function init() {
  const network = 'devnet' as Network;
  const packageId =
    '0x85a8c834987bd962d1ed7ccc92bc514ffc46425acc46ca022c0375551181e9d5';
  // const packageId = process.env.PACKAGE_ID;
  const metadata = await loadMetadata(network, packageId);
  const privateKey = process.env.PRIVATE_KEY;

  const obelisk = new Obelisk({
    networkType: network as Network,
    packageId: packageId,
    metadata: metadata,
    secretKey: privateKey,
  });
  let faucetRes = await obelisk.requestFaucet(
    network,
    packageId
  );
  console.log(faucetRes);

  console.log('\n======= send inc transaction ========');

 
 

  const res =
    (await obelisk.tx.aggr.bind_user([
        "helloworld",
        '0xa671cca226518df2612bebefb73520d92de8d7dd58c5bedadad21af3df9bf59d',
    ])) as Types.PendingTransaction;
  console.log(res.hash);

  console.log('=======================================\n');
  await delay(1000);

//   const balance = await obelisk.getBalance();
//   console.log(balance);
}

init();