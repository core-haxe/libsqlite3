package cases;

import cases.util.RecordUtils;
import sqlite.Sqlite;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestQuery extends Test {
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
    
    function testBasicSelect(async:Async) {
        var db = Sqlite.open("persons.db");
        var stmt = db.prepare("SELECT * FROM Person");
        var rs = RecordUtils.toArray(stmt.executeQuery());

        Assert.equals(4, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);

        Assert.equals(rs[2].personId, 3);
        Assert.equals(rs[2].firstName, "Tim");
        Assert.equals(rs[2].lastName, "Mallot");
        Assert.equals(rs[2].iconId, 2);
        
        db.close();
        async.done();
    }

    function testBasicSelectWhere(async:Async) {
        var db = Sqlite.open("persons.db");
        var stmt = db.prepare("SELECT * FROM Person WHERE personId = 1");
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
        var stmt = db.prepare("SELECT * FROM Person WHERE personId = 1 OR personId = 4");
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
        var stmt = db.prepare("SELECT * FROM Person WHERE personId = 1 AND firstName = 'Ian'");
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