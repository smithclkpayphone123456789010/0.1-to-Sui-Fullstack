#[allow(unused_variable, lint(self_transfer))]
module admin::week_four {
    //==============================================================================================
    // Dependencies
    //==============================================================================================
    use std::string::{Self, String};
    use sui::event;
    use sui::table::{Self, Table};
    use sui::coin::{Self, Coin};
    use std::type_name::{Self, TypeName};
    use sui::balance::{Self, Balance};
    use sui::dynamic_field;
    use sui::dynamic_object_field;
    use std::ascii::{String as AString};

    //==============================================================================================
    // Constants
    //==============================================================================================

    //==============================================================================================
    // Error codes
    //==============================================================================================
    //// You already have a Profile
    const EProfileExist: u64 = 1;
    const ENotInFolder: u64 = 2;

    //==============================================================================================
    // Structs 
    //==============================================================================================
    public struct State has key{
        id: UID,
        // users: vector<address>,
        //alternative <owner_address, profile_object_address>
        users: Table<address, address>,
    }
    
    public struct Profile has key{
        id: UID,
        name: String,
        description: String,
        folders: vector<address>,
    }

    public struct Folder has key, store{
        id: UID,
        name: String,
        description: String,
    }

    //==============================================================================================
    // Event Structs 
    //==============================================================================================
    public struct ProfileCreated has copy, drop {
        profile: address,
        owner: address,
    }

    public struct FolderCreated has copy, drop{
        id: ID,
        owner: address
    }

    public struct CoinWrapped has copy, drop{
        folder: address,
        coin_type: AString,
        amount: u64,
        new_balance: u64,
    }

    public struct ObjWrapped has copy, drop{
        description: String,
        folder: address,
        obj_add: address,
        obj_type: AString
    }

    public struct CoinUnwrapped has copy, drop{
        folder: address,
        coin_type: AString,
        amount: u64,
    }

    public struct ObjUnwrapped has copy, drop{
        description: String,
        folder: address,
        obj_add: address,
        obj_type: AString
    }

    //==============================================================================================
    // Init
    //==============================================================================================
    fun init(ctx: &mut TxContext) {
        transfer::share_object(State{
            id: object::new(ctx), 
            users: table::new(ctx),
        });
    }

    //==============================================================================================
    // Entry Functions 
    //==============================================================================================
    public entry fun create_profile(
        name: String, 
        description: String, 
        state: &mut State,
        ctx: &mut TxContext
    ){
        let owner = tx_context::sender(ctx);
        assert!(!table::contains(&state.users, owner), EProfileExist);
        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);
        let new_profile = Profile {
            id: uid,
            name,
            description,
            folders: vector::empty(),
        };
        transfer::transfer(new_profile, owner);
        table::add(&mut state.users, owner, object::id_to_address(&id));
        event::emit(ProfileCreated{
            profile: object::id_to_address(&id),
            owner,
        });
    }

    public entry fun create_folder(
        name: String,
        description: String,
        profile: &mut Profile,
        ctx: &mut TxContext
    ){
        let owner = tx_context::sender(ctx);
        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);
        let new_folder = Folder {
            id: uid,
            name,
            description,
        };
        transfer::transfer(new_folder, owner);
        vector::push_back(&mut profile.folders, object::id_to_address(&id));
        event::emit(FolderCreated{
            id,
            owner
        });
    }

    public entry fun add_coin_to_folder<T>(
        folder: &mut Folder,
        coin: Coin<T>,
        ctx: &mut TxContext,
    ){
        let type_name = type_name::get<T>();
        let amount = coin::value(&coin);
        let total;
        if(!dynamic_field::exists_(&folder.id, type_name)){
            dynamic_field::add(&mut folder.id, type_name, coin::into_balance(coin));
            total = amount;
        }else{
            let old_value = dynamic_field::borrow_mut<TypeName, Balance<T>>(&mut folder.id, type_name);
            balance::join(old_value, coin::into_balance(coin));
            total = balance::value(old_value);
        };
        event::emit(CoinWrapped{
            folder: object::uid_to_address(&folder.id),
            coin_type: type_name::into_string(type_name),
            amount,
            new_balance: total,
        })
    }

    public entry fun add_nft_to_folder<T: store+key>(
        folder: &mut Folder,
        nft: T,
        ctx: &mut TxContext,
    ){
        add_obj_to_folder(
            folder, 
            nft, 
            string::utf8(b"add nft to folder")
        );
    }

    public entry fun add_subfolder_to_folder(
        folder: &mut Folder,
        subfolder: Folder,
        ctx: &mut TxContext,
    ){
        add_obj_to_folder(
            folder, 
            subfolder, 
            string::utf8(b"add subfolder to folder")
        );
    }

    public fun remove_coin_from_folder<T>(
        folder: &mut Folder,
        type_name: TypeName,
        ctx: &mut TxContext,
    ): Coin<T>{
        assert!(dynamic_field::exists_(&folder.id, type_name), ENotInFolder);
        let balance = dynamic_field::remove<TypeName, Balance<T>>(&mut folder.id, type_name);
        let coin = coin::from_balance(balance, ctx);
        event::emit(CoinUnwrapped{
            folder: object::uid_to_address(&folder.id),
            coin_type: type_name::into_string(type_name),
            amount: coin::value(&coin)
        });
        coin
    }

    public fun remove_nft_from_folder<T: store+key>(
        folder: &mut Folder,
        nft_obj_add: address,
        ctx: &mut TxContext,
    ): T{
        remove_obj_from_folder(
            folder, 
            nft_obj_add, 
            string::utf8(b"removed nft from folder")
        )
    }

    public fun remove_subfolder_from_folder(
        folder: &mut Folder,
        nft_obj_add: address,
        ctx: &mut TxContext,
    ){
        let subfolder = remove_obj_from_folder<Folder>(
            folder, 
            nft_obj_add, 
            string::utf8(b"removed subfolder from folder")
        );
        transfer::transfer(subfolder, tx_context::sender(ctx));
    }

    //==============================================================================================
    // Getter Functions 
    //==============================================================================================
    public fun check_if_has_profile(
        user_wallet_address: address,
        state: &State,
    ): Option<address>{
        if(table::contains(&state.users, user_wallet_address)){
            option::some(*table::borrow(&state.users, user_wallet_address))
        }else{
            option::none()
        }
    }

    public fun get_balance<T>(
        folder: &Folder
    ): u64{
        if(dynamic_field::exists_(&folder.id, type_name::get<T>())){
            balance::value(dynamic_field::borrow<TypeName, Balance<T>>(&folder.id, type_name::get<T>()))
        }else{
            0
        }   
    }

    public fun check_if_obj_exists_in_folder(
        folder: &Folder,
        obj_add: address
    ): bool{
        dynamic_object_field::exists_(&folder.id, obj_add)
    }

    //==============================================================================================
    // Helper Functions 
    //==============================================================================================
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }

    fun add_obj_to_folder<T: store+key>(
        folder: &mut Folder,
        obj: T,
        description: String,
    ){
        let type_name = type_name::get<T>();
        let obj_add = object::id_to_address(&object::id(&obj));
        dynamic_object_field::add(&mut folder.id, obj_add, obj);
        event::emit(ObjWrapped{
            description,
            folder: object::uid_to_address(&folder.id),
            obj_add,
            obj_type: type_name::into_string(type_name),
        })
    }

    fun remove_obj_from_folder<T: store+key>(
        folder: &mut Folder,
        obj_add: address,
        description: String,
    ): T{
        assert!(dynamic_object_field::exists_(&folder.id, obj_add), ENotInFolder);
        let obj = dynamic_object_field::remove<address, T>(&mut folder.id, obj_add);
        event::emit(ObjUnwrapped{
            description,
            folder: object::uid_to_address(&folder.id),
            obj_add,
            obj_type: type_name::into_string(type_name::get<T>())
        });
        obj
    }
}
