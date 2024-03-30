module opennet::conduct {
    use std::vector;
    use std::string::String;
    use std::from_bcs;
    use aptos_framework::signer;
    use std::table::{Self, Table};
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::resource_account::{Self};

    const EINBOX_NOT_EXIST : u64 = 1001;

    struct Message has store, copy {
        sender: address,
        content: String,
        timestamp: u64,
    }

    struct Inbox has key, store {
        messages: Table<address, Table<address, vector<Message>>>,
    }

    struct MessageCap has key {
        signer_cap: SignerCapability,
    }

    struct Capability has drop, key {
        common_account: address,
    }

    public entry fun create(sender: &signer) {
        let (resource_signer, signer_cap) = account::create_resource_account(sender, x"01");
        
        // let signer_cap = resource_account::retrieve_resource_account_cap(sender, @opennet);
        // let resource_signer = account::create_signer_with_capability(&signer_cap);

        move_to(
            &resource_signer,
            Inbox {
                messages: table::new(),
            }
        );

        move_to(&resource_signer, MessageCap { signer_cap });
    }

    public entry fun send_msg(sender: &signer, recipient_addr: address, content: String, timestamp: u64) 
        acquires MessageCap, Inbox {
        let sender_addr = signer::address_of(sender);

        let opennet_signer_address = get_inbox_signer_address();


        let inbox = borrow_global_mut<Inbox>(opennet_signer_address);
        let messages = &mut inbox.messages; 

        let receipt_exists = table::contains(messages, recipient_addr);
        if (!receipt_exists) {
            let msg_table = table::new<address, vector<Message>>();
            let msg_vector = vector::empty<Message>();
            vector::push_back(&mut msg_vector, Message {
                content, 
                sender : sender_addr,
                timestamp : timestamp
            });
            table::add(&mut msg_table, sender_addr, msg_vector);
            table::add(messages, recipient_addr, msg_table);
        } else {
            let msg_table = table::borrow_mut(messages, recipient_addr);
            let msg_vector = table::borrow_mut(msg_table, sender_addr);
            vector::push_back(msg_vector, Message {
                content, 
                sender : sender_addr,
                timestamp : timestamp
            });
        }
    } 

    fun get_inbox_signer_address() : address acquires MessageCap {
        assert!(@opennet == from_bcs::to_address(x"2a17af9e3bf74f3ddf9e5346fc2c4ba136af3d94e5c0476ebc678c0ae4bbd614"), 2000);
        let common_addr = account::create_resource_address(&@opennet, x"01");

        let opennet = &borrow_global<MessageCap>(common_addr).signer_cap;
        let opennet_signer = &account::create_signer_with_capability(opennet);
        let opennet_signer_address = signer::address_of(opennet_signer);

        opennet_signer_address
    }

    #[view]
    public fun get_messages(recipient_addr : address, sender_addr : address) : vector<Message> acquires Inbox{
        
        let  messages = &borrow_global<Inbox>(@opennet).messages;

        let receipt_exists = table::contains(messages, recipient_addr);
        assert!(!receipt_exists, EINBOX_NOT_EXIST);

        let msg_table = table::borrow(messages, recipient_addr);
        let msg_vector = table::borrow(msg_table, sender_addr);

        let results = vector::empty<Message>();
        let len = vector::length(msg_vector);
        let i = 0;
        while (i < len) {
            vector::push_back(&mut results, *vector::borrow<Message>(msg_vector, i));
            i = i + 1;
        };
        results
    }

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use aptos_framework::block;
    #[test_only]
    use std::debug;

    #[test(acct = @0x123, bob = @0x456)]
    public entry fun test_send_msg(acct: &signer, bob: &signer) acquires MessageCap, Inbox{
        account::create_account_for_test(signer::address_of(acct));
        // account::create_account_for_test(signer::address_of(bob));
        let alice_addr = signer::address_of(acct);
        let bob_addr = signer::address_of(bob);

        // let common_addr = account::create_resource_address(&alice_addr, x"01");
        
        create(acct); //init module
        // debug::print(&common_addr);

        // let resource = borrow_global<MessageCap>(common_addr);

        // let resource = borrow_global<CommonAccount>(common_account);
        // account::create_signer_with_capability(&resource.signer_cap)

        send_msg(acct, bob_addr, string::utf8(b"test"), 123423423);
    }
}