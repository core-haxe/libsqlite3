package cases;

import cases.util.RecordUtils;
import sqlite.Sqlite;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestPreparedQuery extends Test {
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
    
    function testBasicSelectWhere(async:Async) {
        var db = Sqlite.open("persons.db");
        var stmt = db.prepare("SELECT * FROM Person WHERE personId = ?");
        stmt.bindInt(1, 1);
        var rs = RecordUtils.toArray(stmt.executeQuery());

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        
        db.close();
        async.done();
    }

    function testBasicSelectWhereOr(async:Async) {
        var db = Sqlite.open("persons.db");
        var stmt = db.prepare("SELECT * FROM Person WHERE personId = ? OR personId = ?");
        stmt.bindInt(1, 1);
        stmt.bindInt(2, 4);
        var rs = RecordUtils.toArray(stmt.executeQuery());

        Assert.equals(2, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);

        Assert.equals(rs[1].personId, 4);
        Assert.equals(rs[1].firstName, "Jim");
        Assert.equals(rs[1].lastName, "Parker");
        Assert.equals(rs[1].iconId, 1);
        
        db.close();
        async.done();
    }

    function testBasicSelectWhereAnd(async:Async) {
        var db = Sqlite.open("persons.db");
        var stmt = db.prepare("SELECT * FROM Person WHERE personId = ? AND firstName = ?");
        stmt.bindInt(1, 1);
        stmt.bindString(2, "Ian");
        var rs = RecordUtils.toArray(stmt.executeQuery());

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        
        db.close();
        async.done();
    }
}