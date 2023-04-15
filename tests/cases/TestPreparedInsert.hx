package cases;

import cases.util.RecordUtils;
import sqlite.Sqlite;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestPreparedInsert extends Test {
    function setupClass(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        DBCreator.create().then(_ -> {
            async.done();
        });
    }

    function teardownClass(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        DBCreator.delete();
        async.done();
    }
    
    function testBasicInsert(async:Async) {
        var db = Sqlite.open("persons.db");

        var stmt = db.prepare("INSERT INTO Person (lastName, firstName, iconId) VALUES (?, ?, ?)");
        stmt.bindString(1, "new last name");
        stmt.bindString(2, "new first name");
        stmt.bindInt(3, 1);
        stmt.executeQuery();

        var lastInsertedId = db.lastInsertRowId();
        Assert.equals(5, lastInsertedId);

        var stmt = db.prepare("SELECT * FROM Person WHERE personId = " + lastInsertedId);
        var rs = RecordUtils.toArray(stmt.executeQuery());

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 5);
        Assert.equals(rs[0].firstName, "new first name");
        Assert.equals(rs[0].lastName, "new last name");
        Assert.equals(rs[0].iconId, 1);
        
        db.close();
        async.done();
    }
}