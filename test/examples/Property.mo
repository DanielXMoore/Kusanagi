import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Types "types";

module Property {
    public type Properties = [Property];

    private func toMap(ps : Properties) : HashMap.HashMap<Text,Property> {
        let m = HashMap.HashMap<Text,Property>(ps.size(), Text.equal, Text.hash);
        for (property in ps.vals()) {
            m.put(property.name, property);
        };
        m;
    };

    private func fromMap(m : HashMap.HashMap<Text,Property>) : Properties {
        var ps : Properties = [];
        for ((_, p) in m.entries()) {
            ps := Array.append(ps, [p]);
        };
        ps;
    };

    // Returns a subset of from properties based on the given query.
    // NOTE: ignores unknown properties.
    public func get(properties : Properties, qs : [Query]) : Result.Result<Properties, Types.Error> {
        let m               = toMap(properties);
        var ps : Properties = [];
        for (q in qs.vals()) {
            switch (m.get(q.name)) {
                case (null) {
                    // Query contained an unknown property.
                    return #err(#NotFound);
                };
                case (? p)  {
                    switch (p.value) {
                        case (#Class(c)) {
                            if (q.next.size() == 0) {
                                // Return every sub-attribute attribute.
                                ps := Array.append(ps, [p]);
                            } else {
                                let sps = switch (get(c, q.next)) {
                                    case (#err(e)) { return #err(e); };
                                    case (#ok(v))  { v; };
                                };
                                ps := Array.append(ps, [{
                                    name      = p.name;
                                    value     = #Class(sps);
                                    immutable = p.immutable;
                                }]);
                            };
                        };
                        case (other) {
                            // Not possible to get sub-attribute of a non-class property.
                            if (q.next.size() != 0) {
                                return #err(#NotFound);
                            };
                            ps := Array.append(ps, [p]);
                        };
                    }
                };
            };
        };
        #ok(ps);
    };

    // Updates the given properties based on the given update query.
    // NOTE: creates unknown properties.
    public func update(properties : Properties, us : [Update]) : Result.Result<Properties, Types.Error> {
        let m = toMap(properties);
        for (u in us.vals()) {
            switch (m.get(u.name)) {
                case (null) {
                    // Update contained an unknown property, so it gets created.
                    switch (u.mode) {
                        case (#Next(sus)) {
                            let sps = switch(update([], sus)) {
                                case (#err(e)) { return #err(e); };
                                case (#ok(v))  { v; };
                            };
                            m.put(u.name, {
                                name      = u.name;
                                value     = #Class(sps);
                                immutable = false;
                            });
                        };
                        case (#Set(v)) {
                            m.put(u.name, {
                                name      = u.name;
                                value     = v;
                                immutable = false;
                            });
                        };
                    };
                };
                case (? p)  {
                    // Can not update immutable property.
                    if (p.immutable) {
                        return #err(#Immutable);
                    };
                    switch (u.mode) {
                        case (#Next(sus)) {
                            switch (p.value) {
                                case (#Class(c)) {
                                    let sps = switch(update(c, sus)) {
                                        case (#err(e)) { return #err(e); };
                                        case (#ok(v))  { v; };
                                    };
                                    m.put(u.name, {
                                        name      = p.name;
                                        value     = #Class(sps);
                                        immutable = false;
                                    });
                                };
                                case (other) {
                                    // Not possible to update sub-attribute of a non-class property.
                                    return #err(#NotFound);
                                };
                            };
                            return #err(#NotFound);
                        };
                        case (#Set(v)) {
                            m.put(u.name, {
                                name      = p.name;
                                value     = v;
                                immutable = false;
                            });
                        };
                    };
                };
            };
        };
        #ok(fromMap(m));
    };

    public type Property = {
        name      : Text;
        value     : Value;
        immutable : Bool;
    };

    public type Value = {
        #Int       : Int;
        #Nat       : Nat;
        #Float     : Float;
        #Text      : Text;
        #Bool      : Bool;
        #Class     : [Property];
        #Principal : Principal;
        #Empty;
    };

    // Specifies the list of properties that are queried.
    public type QueryRequest = {
        id   : Text;
        mode : QueryMode;
    };

    public type Query = {
        name : Text;    // Target property name.
        next : [Query]; // Optional sub-properties in the case of a class value.
    };

    public type QueryMode = {
        #All;            // Returns all properties.
        #Some : [Query]; // Returns a select set of properties based on the name.
    };

    // Specifies the properties that should be updated to a certain value.
    public type UpdateRequest = {
        id     : Text;
        update : [Update];
    };

    public type Update = {
        name : Text;
        mode : UpdateMode;
    };

    public type UpdateMode = {
        #Set    : Value;
        #Next   : [Update];
    };
}
