#[test_only]
module admin::week_three_tests {
    use admin::week_three::{Self, State, Profile, Folder} ;
    use sui::test_scenario::{Self};
    use sui::test_utils::assert_eq;
    use std::string;
    use admin::nft::{Self, Pet, Toy};
    // use std::debug;

    //const ENotImplemented: u64 = 0;

    #[test]
    fun test_create_profile_create_folder_wrap_nft() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_three::init_for_testing(test_scenario::ctx(scenario));
        
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_three::create_profile(
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
            week_three::create_folder(
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

        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let pet_nft = test_scenario::take_from_sender<Pet>(scenario);
            week_three::add_nft_to_folder<Pet>(
                &mut folder, 
                pet_nft,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_three::check_if_nft_type_exists<Pet>(&folder), true);
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_wrap_toy_wrap_nft() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        
        week_three::init_for_testing(test_scenario::ctx(scenario));
        
        test_scenario::next_tx(scenario, user);
        let name = string::utf8(b"Bob");
        let desc = string::utf8(b"degen");
        {
            let mut state = test_scenario::take_shared<State>(scenario);
            week_three::create_profile(
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
            week_three::create_folder(
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


            let name = string::utf8(b"Ball");
            let description = string::utf8(b"tennis_ball");
            let category = string::utf8(b"Toy");
            let image = string::utf8(b"toy_image_url");
            nft::mint_nft(name, description, category, image, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, profile);
        };

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

        test_scenario::next_tx(scenario, user);
        {
            let pet = test_scenario::take_from_sender<Pet>(scenario);
            assert_eq(nft::check_if_pet_carries_toy_or_accessory<Toy>(&pet), true);
            test_scenario::return_to_sender(scenario, pet);
        };

        test_scenario::next_tx(scenario, user);
        {
            let mut folder = test_scenario::take_from_sender<Folder>(scenario);
            let pet_nft = test_scenario::take_from_sender<Pet>(scenario);
            week_three::add_nft_to_folder<Pet>(
                &mut folder, 
                pet_nft,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::next_tx(scenario, user);
        {
            let folder = test_scenario::take_from_sender<Folder>(scenario);
            assert_eq(week_three::check_if_nft_type_exists<Pet>(&folder), true);
            test_scenario::return_to_sender(scenario, folder);
        };

        test_scenario::end(scenario_val);
    }

    // #[test, expected_failure(abort_code = admin::week_three_tests::ENotImplemented)]
    // fun test_week_three_fail() {
    //     abort ENotImplemented
    // }
}

