package cases;

import haxe.io.Bytes;
import cases.util.RecordUtils;
import sqlite.Sqlite;
import utest.Assert;
import utest.Test;
import cases.util.DBCreator;
import utest.Async;

class TestBlob extends Test {    
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

    function testBasicBlob(async:Async) {
        var db = Sqlite.open("persons.db");
        var stmt = db.prepare("SELECT * FROM Person WHERE personId = 1");
        var rs = RecordUtils.toArray(stmt.executeQuery());

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.isOfType(rs[0].contractDocument, Bytes);
        Assert.equals(Bytes.ofString("this is ians contract document").toString(), rs[0].contractDocument.toString());
        
        async.done();
    }
}