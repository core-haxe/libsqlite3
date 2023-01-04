package sqlite;

import cpp.RawPointer;
import cpp.ConstCharStar;
import cpp.Pointer;
import cpp.Finalizable;
import sqlite.RawSqlite.*;
import sqlite.RawSqlite.RawSqliteStmt;
import haxe.Exception;

@:unreflective
class SqliteDatabase extends Finalizable {
    private var db:Pointer<RawSqlite>;
    private var cache = new Map<String, SqliteStatement>();

    public function new(db:Pointer<RawSqlite>) {
        super();
        this.db = db;
    }

    public function close() {
        sqlite3_close(db.raw);
        db = null;
    }

    public override function finalize() {
        close();
        super.finalize();
    }

    public function prepare(sql:String):SqliteStatement {
        var stmt = cache[sql];
        if (stmt == null) {
            var rawstmt:RawPointer<RawSqliteStmt> = null;
            var rawtail:ConstCharStar = null;

            var i = sqlite3_prepare_v2(db.raw, sql, -1, RawPointer.addressOf(rawstmt), RawPointer.addressOf(rawtail));
            if (i != 0) {
                throw new Exception(sqlite3_errmsg(db.raw));
            }

            var tail:String = rawtail;
            if (tail != "") {
                throw new Exception('Some of statement ignored: "${tail}"');
            }

            stmt = new SqliteStatement(db, Pointer.fromRaw(rawstmt));
            cache[sql] = stmt;
        } else {
            stmt.reset();
        }

        return stmt;
    }
}