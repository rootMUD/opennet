module opennet::aggr {
    use std::signer;
    use std::string::{String};
    use std::vector;
    use std::table::{Self, Table};
    use aptos_framework::account;
    use aptos_framework::account::SignerCapability;
    use aptos_std::simple_map::{Self, SimpleMap};
    use aptos_framework::event;

    struct OpenAggr has key {
        repo: String,
        relation_repos: vector<String>
    }

    struct RepoInfo has key, store {
        repo : String,
        point : u64,
        depend_repos : vector<String>,
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
    entry fun init_module(sender: &signer) {
        let addr_aggr = RepoAggr {
            key_addr: signer::address_of(sender),
            repos_map: table::new(),
            repos: vector::empty<String>(),
            github_user_mapping : table::new(),
            max_id: 0,
        };

        move_to<RepoAggr>(sender, addr_aggr);
    }

    public entry fun bind_user(sender: &signer, github_user: String) 
        acquires RepoAggr {
   
        let sender_addr = signer::address_of(sender);
        let repo_aggr = borrow_global_mut<RepoAggr>(sender_addr);

        let user_mapping = &mut repo_aggr.github_user_mapping;

        let user_exists = table::contains(user_mapping, github_user);
        if (!user_exists) {
            table::add(user_mapping, github_user, sender_addr);
        } 
    }

    public entry fun register_repo(sender: &signer, repo: String, rels: vector<String>)
        acquires RepoAggr {
        let i = 0;
        while (i < vector::length(&rels)) {
            let rel = vector::borrow(&rels, i);
            increase_point(sender, *rel, repo);
        };
    }

    public fun increase_point (sender: &signer, origin_repo: String, depend_repo: String)
        acquires RepoAggr{
   
        let send_addr = signer::address_of(sender);
        let repo_aggr = borrow_global_mut<RepoAggr>(send_addr);

        let repos_map = &mut repo_aggr.repos_map;

        let repo_exists= table::contains(repos_map, origin_repo);
        if (!repo_exists) {
            let repo_info = RepoInfo {
                repo: origin_repo,
                point: 0,
                depend_repos : vector::empty<String>(),
            };

            let depend_repos = &mut repo_info.depend_repos;
            vector::push_back(depend_repos, depend_repo);

            table::add(repos_map, origin_repo, repo_info);
        } else {
            // let depend_repos = table::borrow_mut(repos_map, origin_repo);
            // vector::push_back(depend_repos, RepoInfo{
            //     repo: depend_repo,
            //     point: 0,
            // });
        };

        repo_aggr.max_id = repo_aggr.max_id + 1;

        event::emit(AddRepoEvent { origin_repo : origin_repo, depend_repo : depend_repo});
    }


}