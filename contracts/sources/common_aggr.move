module opennet::common_aggr {
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

    struct RepoPoint has key {
        repo : String,
        point : u64,
        depend_repos : vector<String>,
    }

    struct CommonAccount has key {
        signer_cap: SignerCapability,
    }

    struct Empty has drop, store {}

    struct Management has key {
        admin: address,
        unclaimed_capabilities: SimpleMap<address, Empty>,
    }

    /// A revokable capability that is stored on a users account.
    struct Capability has drop, key {
        common_account: address,
    }

    struct RepoInfo has store {
        repo: String,
        point: u64,
    }

    struct GlobalRepo has key {
        repo_depends : Table<String, vector<RepoInfo>>,
        user_mapping : Table<String, address>,
        repo_count: u64,
    }

    #[event]
    struct AddRepoEvent has drop, store {
        origin_repo : String,
        depend_repo : String
    }

    // // This is only callable during publishing.
    // fun init_module(sender: &signer) {
    //     // let (opennet_signer, opennet_cap) = account::create_resource_account(sender, );

    //     let (resource_signer, signer_cap) = account::create_resource_account(sender, x"01");

    //     move_to(
    //         &resource_signer,
    //         Management {
    //             admin: signer::address_of(sender),
    //             unclaimed_capabilities: simple_map::create(),
    //         },
    //     );

    //     move_to(
    //         &resource_signer,
    //         GlobalRepo {
    //             repo_depends: table::new(),
    //             user_mapping: table::new(),
    //             repo_count: 0,
    //         }
    //     );

    //     move_to(&resource_signer, CommonAccount { signer_cap });
    // }

    public entry fun bind_user(sender: &signer, github_user: String) 
        acquires CommonAccount, GlobalRepo {
        let sender_addr = signer::address_of(sender);
        let opennet_signer_address = get_opennet_signer_address();

        let global_repo = borrow_global_mut<GlobalRepo>(opennet_signer_address);
        let user_mapping = &mut global_repo.user_mapping;

        let user_exists = table::contains(user_mapping, github_user);
        if (!user_exists) {
            table::add(user_mapping, github_user, sender_addr);
        } 
    }


    public entry fun register_repo(sender: &signer, repo: String, rels: vector<String>)
        acquires CommonAccount, GlobalRepo {
        let aggr = OpenAggr {
            repo : repo,
            relation_repos : rels,
        };


        let i = 0;
        while (i < vector::length(&rels)) {
            let rel = vector::borrow(&rels, i);
            increase_point(sender, *rel, repo);
        };

        move_to<OpenAggr>(sender, aggr);
    }


    public fun increase_point (sender: &signer, origin_repo: String, depend_repo: String)
        acquires CommonAccount, GlobalRepo{
        let sender_addr = signer::address_of(sender);
        let opennet_signer_address = get_opennet_signer_address();

        let global_repo = borrow_global_mut<GlobalRepo>(opennet_signer_address);
        let repo_depends = &mut global_repo.repo_depends;

        let repo_exists= table::contains(repo_depends, origin_repo);
        if (!repo_exists) {
            let depend_repos = vector::empty<RepoInfo>();
            vector::push_back(&mut depend_repos, RepoInfo{
                repo: depend_repo,
                point: 0,
            });
            table::add(repo_depends, origin_repo, depend_repos);
        } else {
            let depend_repos = table::borrow_mut(repo_depends, origin_repo);
            vector::push_back(depend_repos, RepoInfo{
                repo: depend_repo,
                point: 0,
            });
        };

        event::emit(AddRepoEvent { origin_repo : origin_repo, depend_repo : depend_repo});
    }

    fun get_opennet_signer_address() : address acquires CommonAccount {
        // let opennet_cap = &borrow_global<CommonAccount>(@opennet).signer_cap;
        // let opennet_signer = &account::create_signer_with_capability(opennet_cap);
        // let opennet_signer_address = signer::address_of(opennet_signer);

        // opennet_signer_address


        let common_addr = account::create_resource_address(&@opennet, x"01");

        let opennet = &borrow_global<CommonAccount>(common_addr).signer_cap;
        let opennet_signer = &account::create_signer_with_capability(opennet);
        let opennet_signer_address = signer::address_of(opennet_signer);

        opennet_signer_address
    }
}