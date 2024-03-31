/* eslint-disable camelcase */
/* eslint-disable prefer-const */
/* eslint-disable spaced-comment */
/* eslint-disable no-unused-vars */
import {
	DAPP_ADDRESS,
	APTOS_FAUCET_URL,
	APTOS_NODE_URL,
	MODULE_URL,
} from '../config/constants';
import { NETWORK, PACKAGE_ID } from '../chain/config';
import { useWallet } from '@manahippo/aptos-wallet-adapter';
import { MoveResource } from '@martiandao/aptos-web3-bip44.js/dist/generated';
import React, { useState, useEffect } from 'react';
import {
	AptosAccount,
	WalletClient,
	HexString,
} from '@martiandao/aptos-web3-bip44.js';
import { connect } from 'http2';
import { InputTransactionData } from '@aptos-labs/wallet-adapter-react';
import { loadMetadata, Network, Obelisk, Types } from '@0xobelisk/aptos-client';

import axios from 'axios';

//import { Aptos, AptosConfig, Network, Account, Ed25519PrivateKey  } from "@aptos-labs/ts-sdk";
//import css from 'styled-jsx/css';

// import { CodeBlock } from "../components/CodeBlock";

// import { TypeTagVector } from "@martiandao/aptos-web3-bip44.js/dist/aptos_types";
// import {TypeTagParser} from "@martiandao/aptos-web3-bip44.js/dist/transaction_builder/builder_utils";
export default function Home() {
const [hasAddrAggregator, setHasAddrAggregator] =
		React.useState<boolean>(false);
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

    let [inputValue1, setInputValue1] = useState('');
	let [inputValue2, setInputValue2] = useState('');
	let [hash, sethash] = useState('');
    let [check, setcheck] = useState([]);


	async function connect_contract() {
		const metadata = await loadMetadata(NETWORK, PACKAGE_ID);

		const obelisk = new Obelisk({
			networkType: NETWORK,
			packageId: PACKAGE_ID,
			metadata,
		});

		const f_payload = (await obelisk.tx.conduct.send_msg(
			[inputValue1, inputValue2], // params
			undefined, // typeArguments
			true
		)) as Types.EntryFunctionPayload;

		const payload: Types.TransactionPayload = {
			type: 'entry_function_payload',
			function: f_payload.function,
			type_arguments: f_payload.type_arguments,
			arguments: f_payload.arguments,
		};

		const txDetail = await signAndSubmitTransaction(payload);
		console.log(txDetail);
		const hash = txDetail.hash;
		sethash(hash);
	}
	//点击按钮提交交易
	async function submitTransation() {
		console.log(inputValue1);
		if (!inputValue1) {
			alert('输入不能为空');
		} else {
			const respose = await connect_contract();
		}
	}

	async function checkRepo() {
		const response = await axios.get(`http://8.218.247.153:8000/github.com/${inputValue1}`);
		console.log(response);
		if(response.status=== 200){
			const list=response.data.data.repos
			console.log(list);
			setcheck(list);

			//const MyComponent: React.FC = (item,index) => {
				//return (
				  //<div>
				//	{/* 使用.map 方法循环渲染列表项 */}
				//	{item.map(item, index) => (
				//	  <b key={index}>{check}</b>
				//	))}
				//  </div>
				//);
			 // }; 
		}
	}

	function change1(ev: any) {
		setInputValue1(ev.target.value);
	}

	function change2(ev: any) {
		setInputValue2(ev.target.value);
	}

  return (  
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        height: '30vh', // 或者指定其他适合的高度值
      }}>
        <div>
        <b> Message To: </b>
        <input
            placeholder="input aptos address"
            className="mt-8 p-4 input input-bordered input-primary "
            value={inputValue1} onChange={(ev)=>{change1(ev)}}
          />
          </div>
          <br />
		  <div>
        <b>Message Content: </b>
        <input
            placeholder="input chat message"
            className="mt-8 p-4 input input-bordered input-primary "
            value={inputValue2} onChange={(ev)=>{change2(ev)}}
          />
          </div>
          <br />
		  
          <div>

          <button className="bg-blue hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded shadow"
          onClick={()=>submitTransation()} style={{
            margin: '40px',
          }}> send msg </button>
          </div>
{/*TODO */}
		  <div style={{ display: check ? 'block' : 'none' }}> 
           <b >{check[0]}</b>
           <br />
		   <b >{check[1]}</b><br />
		   <b >{check[2]}</b><br />
		  </div>
      <br />
		  
		  
     </div>
    
      );

}
