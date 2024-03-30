import { Obelisk, loadMetadata, Types, Network } from '@0xobelisk/aptos-client';
import dotenv from 'dotenv';
dotenv.config();

export const delay = (ms: number) =>
  new Promise((resolve) => setTimeout(resolve, ms));

async function init() {
  const network = 'devnet' as Network;
  const packageId =
    '0x2a17af9e3bf74f3ddf9e5346fc2c4ba136af3d94e5c0476ebc678c0ae4bbd614';
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
    '0x2a17af9e3bf74f3ddf9e5346fc2c4ba136af3d94e5c0476ebc678c0ae4bbd614'
  );
  console.log(faucetRes);

  console.log('\n======= send inc transaction ========');

 
 

  const res =
    (await obelisk.tx.conduct.send_msg([
        '0xa671cca226518df2612bebefb73520d92de8d7dd58c5bedadad21af3df9bf59d',
        "hello world",
        234123412,
    ])) as Types.PendingTransaction;
  console.log(res.hash);

  console.log('=======================================\n');
  await delay(1000);

  // const msgs = await obelisk.query.conduct.get_messages(['0xa671cca226518df2612bebefb73520d92de8d7dd58c5bedadad21af3df9bf59d', 
  //   '0x2a17af9e3bf74f3ddf9e5346fc2c4ba136af3d94e5c0476ebc678c0ae4bbd614']);
  // console.log(msgs);

//   const balance = await obelisk.getBalance();
//   console.log(balance);
}

init();