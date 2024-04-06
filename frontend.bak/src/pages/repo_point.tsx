// import { DAPP_ADDRESS, MODULE_NAME, MODULE_URL, APTOS_NODE_URL } from '../config/constants';
import {
    DAPP_ADDRESS,
    APTOS_NODE_URL,
    NETWORK
  } from "../config/constants";
import { useWallet } from '@manahippo/aptos-wallet-adapter';
import { useEffect, useState } from 'react';
import React from 'react';
import { AptosAccount, AptosClient, BCS, HexString } from 'aptos';

export default function Home() {
    const { account, signAndSubmitTransaction } = useWallet();

    const [addServiceEvents, setAddServiceEvents] = useState<
        Array<{
            name: string;
            description: string;
            url: string;
            verification_url: string;
            expired_at: number;
        }>
        >([{
            name: '',
            description: '',
            url: '',
            verification_url: '',
            expired_at: 0,
        },]);

    const [updateServiceEvents, setUpdateAddServiceEvents] = useState<
        Array<{
            name: string;
            description: string;
            url: string;
            verification_url: string;
            expired_at: number;
        }>
        >([{
            name: '',
            description: '',
            url: '',
            verification_url: '',
            expired_at: 0,
        },]);

    const [deleteServiceEvents, setDeleteAddServiceEvents] = useState<
        Array<{
            name: string;
        }>
        >([{
            name: '',
        },]);
    
    const client = new AptosClient(APTOS_NODE_URL);

    const get_add_service_events = async () => {
        try {
            await client.getEventsByEventHandle(
                account!.address!.toString(),
                DAPP_ADDRESS + '::service_aggregator::ServiceAggregator',
                'add_service_events'
            ).then((events) => {
                console.log(events);
                const data = events.map((event) => {
                    return event.data;
                });
                setAddServiceEvents(data);
            });


        } catch (err) {
            console.log(err);
        }};
    
    const get_update_service_events = async () => {
        try {
            await client.getEventsByEventHandle(
                account!.address!.toString(),
                DAPP_ADDRESS + '::service_aggregator::ServiceAggregator',
                'update_service_events'
            ).then((events) => {
                console.log(events);
                const data = events.map((event) => {
                    return event.data;
                });
                setUpdateAddServiceEvents(data);
            });


        } catch (err) {
            console.log(err);
        }};

    const get_delete_service_events = async () => {
        try {
            await client.getEventsByEventHandle(
                account!.address!.toString(),
                DAPP_ADDRESS + '::service_aggregator::ServiceAggregator',
                'delete_service_events'
            ).then((events) => {
                console.log(events);
                const data = events.map((event) => {
                    return event.data;
                });
                setDeleteAddServiceEvents(data);
            });


        } catch (err) {
            console.log(err);
        }};
    
    const render_add_service_envets = () => {
        return addServiceEvents.map(
            (data, _index) =>
            (
                <tr className="text-center">
                    <th>{data.name}</th>
                    <td>{data.description}</td>
                    <td><a className="underline" href={data.url} target="_blank">{data.url}</a></td>
                    <td><a className="underline"  href={data.verification_url} target="_blank">{data.verification_url}</a></td>
                    <td>{data.expired_at}</td>
                </tr>
            )
        );
    };

    const render_update_service_envets = () => {
        return updateServiceEvents.map(
            (data, _index) =>
            (
                <tr className="text-center">
                    <th>{data.name}</th>
                    <td>{data.description}</td>
                    <td><a className="underline" href={data.url} target="_blank">{data.url}</a></td>
                    <td><a className="underline" href={data.verification_url} target="_blank">{data.verification_url}</a></td>
                    <td>{data.expired_at}</td>
                </tr>
            )
        );
    };

    const render_delete_service_events = () => {
        return deleteServiceEvents.map(
            (data, _index) =>
            (
                <tr className="text-center">
                    <th>{data.name}</th>
                </tr>
            )
        );
    };

    // useEffects
    useEffect(() => {
        get_add_service_events();
    }, [account]);

    useEffect(() => {
        get_update_service_events();
    }, [account]);


    useEffect(() => {
        get_delete_service_events();
    }, [account]);

    return (
        <div className=" p-4 w-[60%] m-auto flex flex-col shadow-2xl opacity-80 mb-10 justify-center ">
            { (account  && account.address) && (
                <div className="overflow-x-auto mt-2">
                <br></br>
                <br></br>
                </div>

            )}
            {/* add_service_events */}
            {addServiceEvents && (
                <div className="overflow-x-auto mt-2">
                    <h3 className="text-center font-bold">
                    </h3>
                    <table className="table table-compact w-full my-2">
                    <thead>
                        <tr className="text-center">
                            <th>Name</th>
                            <th>URL</th>
                            <th>Point</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr className="text-center">
                            <th> opennet </th>
                            <td><a className="underline" href="github.com/tiankonglan/opennet" target="_blank">github.com/tiankonglan/opennet</a></td>
                            <td> 3 </td>
                        </tr>
                        <tr className="text-center">
                            <th> opennet-core </th>
                            <td><a className="underline" href="github.com/tiankonglan/opennet-core" target="_blank">github.com/tiankonglan/opennet-core</a></td>
                            <td> 2 </td>
                        </tr>
                        <tr className="text-center">
                            <th> opennet-toolkit </th>
                            <td><a className="underline" href="github.com/tiankonglan/opennet" target="_blank">github.com/tiankonglan/opennet-toolkit</a></td>
                            <td> 1 </td>
                        </tr></tbody>
                    </table>
                    <br></br>
                </div>
            )}
        </div>


    )
}