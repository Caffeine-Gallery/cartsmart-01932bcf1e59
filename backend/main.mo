import Bool "mo:base/Bool";

import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

actor {
    // Define the structure for a shopping list item
    public type ShoppingItem = {
        id: Nat;
        text: Text;
        completed: Bool;
    };

    private stable var nextId: Nat = 0;
    private stable var itemsEntries: [(Nat, ShoppingItem)] = [];

    private let items = HashMap.HashMap<Nat, ShoppingItem>(
        0, Nat.equal, Hash.hash
    );

    // Initialize items from stable storage
    system func preupgrade() {
        itemsEntries := Iter.toArray(items.entries());
    };

    system func postupgrade() {
        for ((k, v) in itemsEntries.vals()) {
            items.put(k, v);
        };
    };

    // Add a new shopping list item
    public func addItem(text: Text) : async ShoppingItem {
        let item: ShoppingItem = {
            id = nextId;
            text = text;
            completed = false;
        };
        items.put(nextId, item);
        nextId += 1;
        return item;
    };

    // Get all shopping list items
    public query func getItems() : async [ShoppingItem] {
        return Iter.toArray(items.vals());
    };

    // Toggle the completion status of an item
    public func toggleItem(id: Nat) : async ?ShoppingItem {
        switch (items.get(id)) {
            case (null) { null };
            case (?item) {
                let updatedItem: ShoppingItem = {
                    id = item.id;
                    text = item.text;
                    completed = not item.completed;
                };
                items.put(id, updatedItem);
                ?updatedItem
            };
        };
    };

    // Delete an item
    public func deleteItem(id: Nat) : async Bool {
        switch (items.remove(id)) {
            case (null) { false };
            case (?_) { true };
        };
    };
};
