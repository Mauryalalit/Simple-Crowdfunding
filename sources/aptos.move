module MyModule::Crowdfunding {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    const EGOAL_NOT_REACHED: u64 = 1;
    const EALREADY_WITHDRAWN: u64 = 2;

    struct Project has key, store {
        total_funds: u64,
        goal: u64,
        withdrawn: bool,
    }

    public fun create_project(owner: &signer, goal: u64) {
        let project = Project {
            total_funds: 0,
            goal,
            withdrawn: false,
        };
        move_to(owner, project);
    }

    public fun contribute_to_project(
        contributor: &signer,
        project_owner: address,
        amount: u64
    ) acquires Project {
        let project = borrow_global_mut<Project>(project_owner);
        let coins = coin::withdraw<AptosCoin>(contributor, amount);
        coin::deposit<AptosCoin>(project_owner, coins);
        project.total_funds = project.total_funds + amount;
    }

    public fun withdraw_funds(owner: &signer) acquires Project {
        let owner_addr = signer::address_of(owner);
        let project = borrow_global_mut<Project>(owner_addr);

        if (project.total_funds < project.goal) {
            abort EGOAL_NOT_REACHED;
        };

        if (project.withdrawn) {
            abort EALREADY_WITHDRAWN;
        };

        project.withdrawn = true;
    }

    public fun get_project_info(owner: address): (bool, u64, u64) acquires Project {
    if (exists<Project>(owner)) {
        let project = borrow_global<Project>(owner);
        return (project.withdrawn, project.total_funds, project.goal)
    } else {
        return (false, 0, 0)
    }
}

}
