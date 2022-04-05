*** Settings ***
Documentation     Testing database related features.

Library    Collections
Library    RPA.Database
Library    RPA.FileSystem


*** Tasks ***
Returning database query
    # Connect to a local SQLite3 DB saved locally as "orders.db".
    Connect To Database    sqlite3    orders.db    autocommit=${True}
    
    # Create from scratch an "orders" table and insert into it some values.
    Query    DROP TABLE IF EXISTS orders;
    Query    CREATE TABLE orders(id INTEGER PRIMARY KEY, name TEXT);
    Query    INSERT INTO orders(id, name) VALUES(1, "my-1st-order"),(2, "my-2nd-order");
    
    # Inserting with returning. (automatically detects if it should return)
    ${orders_ids} =     Query    INSERT INTO orders(id, name) VALUES(3, "my-3rd-order") RETURNING id;    returning=${True}
    Log    Order ID: ${orders_ids}[0][0]  # Order ID: 3
    
    @{orders} =    Query    SELECT id,name FROM orders
    FOR   ${order}  IN  @{orders}
        # {'id': 1, 'name': 'my-1st-order'}
        # {'id': 2, 'name': 'my-2nd-order'}
        # {'id': 3, 'name': 'my-3rd-order'}
        Log  ${order}
    END


Join users and roles
    Remove File    my-test.db
    Connect To Database  sqlite3  my-test.db
    # Connect To Database    pyodbc    master    host=localhost\\SQLEXPRESS

    Query  CREATE TABLE Roles (role_id INTEGER, role_name TEXT)
    Query  INSERT INTO Roles (role_id, role_name) VALUES (11, 'role1')
    Query  INSERT INTO Roles (role_id, role_name) VALUES (12, 'role2')

    Query  CREATE TABLE Users (id INTEGER, name TEXT, roleID INTEGER)
    Query  INSERT INTO Users (id, name, roleID) VALUES (1, 'aaaaa', 11)
    Query  INSERT INTO Users (id, name, roleID) VALUES (2, 'bbbbb', 12)

    ${result} =  Query  SELECT * FROM Users    assertion=row_count == 2
    Log List    ${result}

    ${result} =    Query    SELECT u.name, r.role_name FROM Users u JOIN Roles r ON u.roleID = r.role_id
    FOR  ${row}  IN  @{result}
        Log To Console   ${row}
    END


Query my database test
    connect to database     module_name=pyodbc  database=master
    ...                     host=localhost\\SQLEXPRESS    port=1433
    @{query_result}    query    SELECT * FROM Users    assertion=row_count > 0
    log  ${query_result}
    disconnect from database
