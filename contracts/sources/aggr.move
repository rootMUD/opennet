module opennet::aggr {
    use std::signer;
    use std::string::{String};
    use std::vector;
    use std::table::{Self, Table};
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::event;

 
    struct RepoInfo has key, store {
        repo : String,
        point : u64,
        quote_repos : vector<String>,
    }

    struct RepoResult has key, store {
        repo : String,
        point : u64,
    }

    struct RepoAggr has key {
        key_addr: address,
        repos_map: Table<String, RepoInfo>,
        repos: vector<String>,
        github_user_mapping : Table<String, address>,
        max_id: u64,
    }

    #[event]
    struct AddRepoEvent has drop, store {
        origin_repo : String,
        depend_repo : String
    }

     // Init.
    fun create(sender: &signer) {
        let addr_aggr = RepoAggr {
            key_addr: signer::address_of(sender),
            repos_map: table::new(),
            repos: vector::empty<String>(),
            github_user_mapping : table::new(),
            max_id: 0,
        };

        move_to<RepoAggr>(sender, addr_aggr);
    }

    public entry fun bind_user(sender: &signer, github_user: String, addr: address) 
        acquires RepoAggr {

        let sender_addr = signer::address_of(sender);

        if (!exists<RepoAggr>(sender_addr)) {
            let addr_aggr = RepoAggr {
                key_addr: signer::address_of(sender),
                repos_map: table::new(),
                repos: vector::empty<String>(),
                github_user_mapping : table::new(),
                max_id: 0,
            };

            move_to<RepoAggr>(sender, addr_aggr);
        };

        let repo_aggr = borrow_global_mut<RepoAggr>(sender_addr);

        let user_mapping = &mut repo_aggr.github_user_mapping;

        let user_exists = table::contains(user_mapping, github_user);
        if (!user_exists) {
            table::add(user_mapping, github_user, addr);
        } 

        
        
    }

    public entry fun register_repo(sender: &signer, repo: String, rels: vector<String>)
        acquires RepoAggr {

        let sender_addr = signer::address_of(sender);

        if (!exists<RepoAggr>(sender_addr)) {
            let addr_aggr = RepoAggr {
                key_addr: signer::address_of(sender),
                repos_map: table::new(),
                repos: vector::empty<String>(),
                github_user_mapping : table::new(),
                max_id: 0,
            };

            move_to<RepoAggr>(sender, addr_aggr);
        };    

        let i = 0;
        while (i < vector::length(&rels)) {
            let rel = vector::borrow(&rels, i);
            increase_point(sender, *rel, repo);
            i = i + 1;
        };
    }

    fun increase_point (sender: &signer, origin_repo: String, depend_repo: String)
        acquires RepoAggr{
   
        let send_addr = signer::address_of(sender);
        let repo_aggr = borrow_global_mut<RepoAggr>(send_addr);

        let repos_map = &mut repo_aggr.repos_map;

        let repo_exists= table::contains(repos_map, origin_repo);
        if (!repo_exists) {
            let repo_info = RepoInfo {
                repo: origin_repo,
                point: 0,
                quote_repos : vector::empty<String>(),
            };

            let quote_repos = &mut repo_info.quote_repos;
            vector::push_back(quote_repos, depend_repo);

            table::add(repos_map, origin_repo, repo_info);

            repo_aggr.max_id = repo_aggr.max_id + 1;
        } else {
            let repo_info = table::borrow_mut(repos_map, origin_repo);
            
            vector::push_back(&mut repo_info.quote_repos, depend_repo);
        };

        event::emit(AddRepoEvent { origin_repo : origin_repo, depend_repo : depend_repo});
    }





    // ----- test ------ 
    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use aptos_framework::block;
    #[test_only]
    use std::debug;

    #[test(acct = @0x123, bob = @0x456)]
    public entry fun test_bind_user(acct: &signer, bob: &signer) acquires RepoAggr {
        account::create_account_for_test(signer::address_of(acct));

        let alice_addr = signer::address_of(acct);
        let bob_addr = signer::address_of(bob);

        // init_module(acct); //init module

        bind_user(acct, string::utf8(b"harryli"), bob_addr);

        let repo_aggr = borrow_global_mut<RepoAggr>(alice_addr);
        assert!(repo_aggr.max_id == 0, 1001);
    }

    #[test(acct = @0x123, bob = @0x456)]
    public entry fun test_register_repo(acct: &signer, bob: &signer) acquires RepoAggr  {
        account::create_account_for_test(signer::address_of(acct));

        let alice_addr = signer::address_of(acct);
        let bob_addr = signer::address_of(bob);

        // init_module(acct); //init module

        // bind_user(acct, string::utf8(b"harryli"), bob_addr);

        let depend_repos = vector::empty<String>();
        vector::push_back(&mut depend_repos, string::utf8(b"github.com/alice"));
        vector::push_back(&mut depend_repos, string::utf8(b"github.com/bob"));
        vector::push_back(&mut depend_repos, string::utf8(b"github.com/alex"));

        register_repo(acct, string::utf8(b"github.com/tom"), depend_repos);


        let repo_aggr = borrow_global_mut<RepoAggr>(alice_addr);
        assert!(repo_aggr.max_id == 3, 1002);
    }
}

