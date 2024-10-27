#[allow(unused_variable, unused_use)]
#[test_only]
module admin::week_four_tests {
    use admin::week_four::{Self, State, Profile, Folder} ;
    use sui::test_scenario::{Self};
    use sui::test_utils::assert_eq;
    use std::string;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use admin::nft::{Self, Pet, Toy};
    use std::type_name;
    use std::debug;

    public struct DOGE {}

    #[test]
    fun test_create_profile_create_folder_wrap_coin() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_four::init_for_testing(test_scenario::ctx(scenario));
        
        // create profile
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_four::create_profile(
                name, 
                desc, 
                &mut state, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(state);
        };

        // create folder
        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"coins"), 
                string::utf8(b"for all useless coins"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, profile);
        };

        // add coin to folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let coin = sui::coin::mint_for_testing<SUI>(
                1000000, 
                test_scenario::ctx(scenario)
            );
            week_four::add_coin_to_folder<SUI>(
                &mut folder, 
                coin,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, folder);
        };

        // check that coin is in folder
        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_four::get_balance<SUI>(&folder), 1000000);
            test_scenario::return_to_sender(scenario, folder);
        };

        // add a different coin to folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let coin = sui::coin::mint_for_testing<DOGE>(
                10000000, 
                test_scenario::ctx(scenario)
            );
            week_four::add_coin_to_folder<DOGE>(
                &mut folder, 
                coin,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, folder);
        };

        // check that coin is in folder
        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_four::get_balance<DOGE>(&folder), 10000000);
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_profile_create_folder_wrap_nft() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_four::init_for_testing(test_scenario::ctx(scenario));
        
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_four::create_profile(
                name, 
                desc, 
                &mut state, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(state);
        };

        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"nfts"), 
                string::utf8(b"for all useless nfts"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );
            let name = string::utf8(b"Lucky");
            let description = string::utf8(b"dog");
            let category = string::utf8(b"Pet");
            let image = string::utf8(b"nft_image_url");
            nft::mint_nft(name, description, category, image, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, profile);
        };

        let pet_nft_obj_add;
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let pet_nft = test_scenario::take_from_sender<Pet>(scenario);
            pet_nft_obj_add = object::id_to_address(object::borrow_id(&pet_nft));
            week_four::add_nft_to_folder<Pet>(
                &mut folder, 
                pet_nft,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, folder);
        };
        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_four::check_if_obj_exists_in_folder(&folder, pet_nft_obj_add), true);
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_wrap_toy_wrap_nft() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_four::init_for_testing(test_scenario::ctx(scenario));
        
        // create Profile
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_four::create_profile(
                name, 
                desc, 
                &mut state, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(state);
        };

        // create subfolder
        // mint Pet and Toy nfts
        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"Pet nfts"), 
                string::utf8(b"subfolder for all Pet nfts"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );

            let name = string::utf8(b"Lucky");
            let description = string::utf8(b"dog");
            let category = string::utf8(b"Pet");
            let image = string::utf8(b"nft_image_url");
            nft::mint_nft(name, description, category, image, test_scenario::ctx(scenario));


            let name = string::utf8(b"Ball");
            let description = string::utf8(b"tennis_ball");
            let category = string::utf8(b"Toy");
            let image = string::utf8(b"toy_image_url");
            nft::mint_nft(name, description, category, image, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, profile);
        };

        // wrap Toy nft into Pet nft -> object owning object
        test_scenario::next_tx(scenario, user);
        {
            let mut pet_nft = test_scenario::take_from_sender<Pet>(scenario);
            let toy_nft = test_scenario::take_from_sender<Toy>(scenario);
            nft::add_toy_or_accessory<Toy>(
                toy_nft, 
                &mut pet_nft,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, pet_nft);
        };

        // check that the Toy obj is indeed wrapped in Pet obj
        test_scenario::next_tx(scenario, user);
        {
            let pet = test_scenario::take_from_sender<Pet>(scenario);
            assert_eq(nft::check_if_pet_carries_toy_or_accessory<Toy>(&pet), true);
            test_scenario::return_to_sender(scenario, pet);
        };

        // wrap Pet into subfolder
        test_scenario::next_tx(scenario, user);
        let pet_nft_obj_add;
        let subfolder_obj_add;
        {
            let mut subfolder = test_scenario::take_from_sender<Folder>(scenario);
            let pet_nft = test_scenario::take_from_sender<Pet>(scenario);
            pet_nft_obj_add = object::id_to_address(object::borrow_id(&pet_nft));
            subfolder_obj_add = object::id_to_address(object::borrow_id(&subfolder));
            week_four::add_nft_to_folder<Pet>(
                &mut subfolder, 
                pet_nft,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, subfolder);
        };

        // create another upper level folder
        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"nft_folder_1"), 
                string::utf8(b"folder for all useless nfts"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, profile);
        };

        // wrap subfolder into higher level folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender_by_id<Folder>(
                scenario, 
            *option::borrow<ID>(&test_scenario::most_recent_id_for_address<Folder>(user))
            );
            let subfolder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_four::check_if_obj_exists_in_folder(&subfolder, pet_nft_obj_add), true);
            week_four::add_subfolder_to_folder(&mut folder, subfolder, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, folder);
        };

        // check that subfolder is indeed wrapped      
        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_four::check_if_obj_exists_in_folder(&folder, subfolder_obj_add), true);
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unwrap_coin() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_four::init_for_testing(test_scenario::ctx(scenario));
        
        // create profile
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_four::create_profile(
                name, 
                desc, 
                &mut state, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(state);
        };

        // create folder
        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"coins"), 
                string::utf8(b"for all useless coins"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, profile);
        };

        // add coin to folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let coin = sui::coin::mint_for_testing<SUI>(
                1000000, 
                test_scenario::ctx(scenario)
            );
            week_four::add_coin_to_folder<SUI>(
                &mut folder, 
                coin,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, folder);
        };

        // check that coin is in folder
        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_four::get_balance<SUI>(&folder), 1000000);
            test_scenario::return_to_sender(scenario, folder);
        };

        // remove coin from folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let coin = week_four::remove_coin_from_folder<SUI>(
                &mut folder, 
                type_name::get<SUI>(),
                test_scenario::ctx(scenario)
            );
            transfer::public_transfer(coin, user);
            test_scenario::return_to_sender(scenario, folder);
        };

        // check that coin is not in folder
        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_four::get_balance<SUI>(&folder), 0);
            let coin = test_scenario::take_from_sender<Coin<SUI>>(scenario);
            assert_eq(coin::value(&coin), 1000000);
            test_scenario::return_to_sender(scenario, folder);
            test_scenario::return_to_sender(scenario, coin);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unwrap_subfolder(){
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_four::init_for_testing(test_scenario::ctx(scenario));
        
        // create Profile
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_four::create_profile(
                name, 
                desc, 
                &mut state, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(state);
        };

        // create subfolder & mint Pet objs
        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"Pet nfts"), 
                string::utf8(b"subfolder for all Pet nfts"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );

            let name = string::utf8(b"Lucky");
            let description = string::utf8(b"dog");
            let category = string::utf8(b"Pet");
            let image = string::utf8(b"nft_image_url");
            nft::mint_nft(name, description, category, image, test_scenario::ctx(scenario));

            let name = string::utf8(b"Purr");
            let description = string::utf8(b"cat");
            let category = string::utf8(b"Pet");
            let image = string::utf8(b"nft_image_url");
            nft::mint_nft(name, description, category, image, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, profile);
        };

        // add Pet objs to subfolder 
        test_scenario::next_tx(scenario, user);
        let subfolder_obj_add;
        {
            let mut subfolder = test_scenario::take_from_sender<Folder>(scenario);
            subfolder_obj_add = object::id_to_address(object::borrow_id(&subfolder));
            let pet_nft = test_scenario::take_from_sender<Pet>(scenario);
            week_four::add_nft_to_folder<Pet>(
                &mut subfolder, 
                pet_nft,
                test_scenario::ctx(scenario)
            );
            let pet_nft = test_scenario::take_from_sender<Pet>(scenario);
            week_four::add_nft_to_folder<Pet>(
                &mut subfolder, 
                pet_nft,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, subfolder);
        };

        // create upper level folder
        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"nft_folder_1"), 
                string::utf8(b"folder for all useless nfts"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, profile);
        };

        // wrap subfolder into upper level folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender_by_id<Folder>(
                scenario, 
            *option::borrow<ID>(&test_scenario::most_recent_id_for_address<Folder>(user))
            );
            let subfolder = test_scenario::take_from_sender<Folder>(scenario);
            week_four::add_subfolder_to_folder(&mut folder, subfolder, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, folder);
        };

        //unwrap subfolder from folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            week_four::remove_subfolder_from_folder(&mut folder, subfolder_obj_add, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, folder);
        };

        //check that subfolder is not in folder
        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            week_four::check_if_obj_exists_in_folder(&folder, subfolder_obj_add);
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = week_four::ENotInFolder)]
    fun test_unwrap_coin_fail_does_not_exist() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_four::init_for_testing(test_scenario::ctx(scenario));
        
        // create profile
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_four::create_profile(
                name, 
                desc, 
                &mut state, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(state);
        };

        // create folder
        test_scenario::next_tx(scenario, user);
        {
            let mut profile = test_scenario::take_from_sender<Profile>(scenario);
            week_four::create_folder(
                string::utf8(b"coins"), 
                string::utf8(b"for all useless coins"), 
                &mut profile, 
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, profile);
        };

        // remove coin from folder
        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let coin = week_four::remove_coin_from_folder<SUI>(
                &mut folder, 
                type_name::get<SUI>(),
                test_scenario::ctx(scenario)
            );
            transfer::public_transfer(coin, user);
            test_scenario::return_to_sender(scenario, folder);
        };
        abort 2
    }
}

