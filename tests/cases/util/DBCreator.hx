package cases.util;

import sqlite.Sqlite;
import sys.io.File;
import sys.FileSystem;
import promises.Promise;

class DBCreator {
    public static function create(createDummyData:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            File.saveContent("persons.db", "");
            var db = Sqlite.open("persons.db");
            var stmt = db.prepare("CREATE TABLE Person (
                personId INTEGER PRIMARY KEY AUTOINCREMENT,
                lastName varchar(50),
                firstName varchar(50),
                iconId int,
                contractDocument blob
            );");
            stmt.executeStatement();

            var stmt = db.prepare("CREATE TABLE Icon (
                iconId int,
                path varchar(50)
            );");
            stmt.executeStatement();

            var stmt = db.prepare("CREATE TABLE Organization (
                organizationId int,
                name varchar(50),
                iconId int
            );");
            stmt.executeStatement();

            var stmt = db.prepare("CREATE TABLE Person_Organization (
                Person_personId int,
                Organization_organizationId int
            );");
            stmt.executeStatement();

            db.close();

            if (createDummyData) {
                addDummyData().then(_ -> {
                    resolve(true);
                });
            } else {
                resolve(true);
            }
        });
    }

    public static function addDummyData():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var db = Sqlite.open("persons.db");

            db.prepare("INSERT INTO Icon (iconId, path) VALUES (1, '/somepath/icon1.png');").executeStatement();
            db.prepare("INSERT INTO Icon (iconId, path) VALUES (2, '/somepath/icon2.png');").executeStatement();
            db.prepare("INSERT INTO Icon (iconId, path) VALUES (3, '/somepath/icon3.png');").executeStatement();

            db.prepare("INSERT INTO Person (personId, firstName, lastName, iconId, contractDocument) VALUES (1, 'Ian', 'Harrigan', 1, X'746869732069732069616e7320636f6e747261637420646f63756d656e74');").executeStatement();
            db.prepare("INSERT INTO Person (personId, firstName, lastName, iconId) VALUES (2, 'Bob', 'Barker', 3);").executeStatement();
            db.prepare("INSERT INTO Person (personId, firstName, lastName, iconId) VALUES (3, 'Tim', 'Mallot', 2);").executeStatement();
            db.prepare("INSERT INTO Person (personId, firstName, lastName, iconId) VALUES (4, 'Jim', 'Parker', 1);").executeStatement();

            db.prepare("INSERT INTO Organization (organizationId, name, iconId) VALUES (1, 'ACME Inc', 2);").executeStatement();
            db.prepare("INSERT INTO Organization (organizationId, name, iconId) VALUES (2, 'Haxe LLC', 1);").executeStatement();
            db.prepare("INSERT INTO Organization (organizationId, name, iconId) VALUES (3, 'PASX Ltd', 3);").executeStatement();

            db.prepare("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (1, 1);").executeStatement();
            db.prepare("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (2, 1);").executeStatement();
            db.prepare("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (3, 1);").executeStatement();
            db.prepare("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (2, 2);").executeStatement();
            db.prepare("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (4, 2);").executeStatement();
            db.prepare("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (1, 3);").executeStatement();
            db.prepare("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (4, 3);").executeStatement();

            db.close();

            resolve(true);
        });
    }

    public static function delete() {
        //FileSystem.deleteFile("persons.db");
    }
}