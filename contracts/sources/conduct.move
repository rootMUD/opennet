module opennet::conduct {
    use std::vector;
    use std::string::String;
    use aptos_framework::signer;
    use std::table::{Self, Table};
    use aptos_framework::account::{Self, SignerCapability};

    struct Message has store {
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

    public fun init(sender: &signer) {
        let (resource_signer, signer_cap) = account::create_resource_account(sender, x"01");

        move_to(
            &resource_signer,
            Inbox {
                messages: table::new(),
            }
        );

        move_to(&resource_signer, MessageCap { signer_cap });
    }

    public fun send_msg(sender: &signer, recipient_addr: address, content: String, timestamp: u64) 
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
        let opennet_cap = &borrow_global<MessageCap>(@opennet).signer_cap;
        let opennet_signer = &account::create_signer_with_capability(opennet_cap);
        let opennet_signer_address = signer::address_of(opennet_signer);

        opennet_signer_address
    }
}