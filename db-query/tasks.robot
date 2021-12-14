*** Settings ***
Documentation     Testing database related features.

Library    RPA.Database


*** Tasks ***
Returning database query
    # Connect to a local SQLite3 DB saved locally as "orders.db".
    Connect To Database    sqlite3    orders.db    autocommit=${True}
    
    # Create from scratch an "orders" table and insert into it some values.
    Query    DROP TABLE IF EXISTS orders;
    Query    CREATE TABLE orders(id INTEGER PRIMARY KEY, name TEXT);
    Query    INSERT INTO orders(id, name) VALUES(1, "my-1st-order"),(2, "my-2nd-order");
    
    # Inserting with returning. (automatically detects that it should return)
    ${orders_ids} =     Query    INSERT INTO orders(id, name) VALUES(3, "my-3rd-order") RETURNING id;
    Log    Order ID: ${orders_ids}[0][0]  # Order ID: 3
    
    @{orders} =    Query    SELECT * FROM orders
    FOR   ${order}  IN  @{orders}
        # {'id': 1, 'name': 'my-1st-order'}
        # {'id': 2, 'name': 'my-2nd-order'}
        # {'id': 3, 'name': 'my-3rd-order'}
        Log  ${order}
    END
