*** Settings ***
Documentation     Testing database related features.

Library    RPA.Database


*** Tasks ***
Returning database query
    Connect To Database    sqlite3    test.db
