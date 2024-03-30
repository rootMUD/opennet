import { DAPP_ADDRESS, APTOS_FAUCET_URL, APTOS_NODE_URL, MODULE_URL } from '../config/constants';
import { useWallet } from '@manahippo/aptos-wallet-adapter';
import { MoveResource } from '@martiandao/aptos-web3-bip44.js/dist/generated';
import { useState, useEffect } from 'react';
import React from 'react';
import { AptosAccount, WalletClient, HexString } from '@martiandao/aptos-web3-bip44.js';
import { connect } from 'http2';
import {InputTransactionData} from "@aptos-labs/wallet-adapter-react";


//import { Aptos, AptosConfig, Network, Account, Ed25519PrivateKey  } from "@aptos-labs/ts-sdk";
//import css from 'styled-jsx/css';

// import { CodeBlock } from "../components/CodeBlock";

// import { TypeTagVector } from "@martiandao/aptos-web3-bip44.js/dist/aptos_types";
// import {TypeTagParser} from "@martiandao/aptos-web3-bip44.js/dist/transaction_builder/builder_utils";
export default function Home() {
  const [hasAddrAggregator, setHasAddrAggregator] = React.useState<boolean>(false);
  const [services, setServices] = React.useState<Array<any>>([]);
  const { account, signAndSubmitTransaction } = useWallet();
  // TODO: refresh page after disconnect.
  const client = new WalletClient(APTOS_NODE_URL, APTOS_FAUCET_URL);
  // const [resource, setResource] = React.useState<MoveResource>();
  const [formInput, updateFormInput] = useState<{
    name: string;
    github_acct: string;
    description: string;
    gist_id: string;
    expired_at: number;
  }>({
    name: 'github',
    github_acct: '',
    description: 'my github account.',
    gist_id: '',
    expired_at: 0,
  });

  let [inputValue1,setInputValue1]=useState("");
  let [inputValue2,setInputValue2]=useState("");

  
//调用合约
  async function transactionContract(args:any,params:any[]){
    const aptosConfig = new AptosConfig({ network: Network.DEVNET});
    const aptos = new Aptos(aptosConfig);
    const account = Account.generate();//生成密钥对


    const privateKey=account.privateKey.toString();
    console.log("privateKey："+privateKey)
    
    console.log("请求参数："+`${args.hash}::${args.module}::${args.method}`)
    console.log("account.accountAddress："+account.accountAddress)
    
    const transaction = await aptos.transaction.build.simple({
      sender: account.accountAddress,
      data: {
          function: `${args.hash}::${args.module}::${args.method}`, 
          functionArguments: params,   //传给合约的信息
          //functionArguments: ,
          //typeArguments: ,
      },
  });
}

async function connect_contract(){
    const args={
      hash:"0xc3a0b686e18cd2f49ee4a8ed721d11ff9483f00bf66258ff38355163df5844ee",
      module:"aggr",
      method:"bind_user",
      params:[
        inputValue2,        
        inputValue1
      ]
    }
  await transactionContract(args,args.params)
  
}
  //点击按钮提交交易
  async function submitTransation(){
    console.log(inputValue1,inputValue2)
    if(!inputValue1||!inputValue2){
      alert("输入不能为空")
    }else{
      const respose=await connect_contract()
    }  
  };

  function change1(ev:any){
    setInputValue1(ev.target.value);
}

function change2(ev:any){
  setInputValue2(ev.target.value);
}

  return (  
      <div>
        <b>https://github.com/</b>
        <input
            placeholder="input repo name"
            className="mt-8 p-4 input input-bordered input-primary w-1/5"
            value={inputValue1} onChange={(ev)=>{change1(ev)}}
          />

        <br></br>
          <b>输入你的钱包地址</b>
         <input
            placeholder="input your wallet address"
            className="mt-8 p-4 input input-bordered input-primary w-1/5"
            value={inputValue2} onChange={(ev)=>{change2(ev)}}
          /> 
          <br></br>
          <button className="bg-blue hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded shadow"
          onClick={()=>submitTransation()} > submit</button>
     </div>
    
      );

}
