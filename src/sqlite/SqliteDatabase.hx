package sqlite;

import cpp.ConstCharStar;
import cpp.Finalizable;
import cpp.Pointer;
import cpp.RawPointer;
import haxe.Exception;
import sqlite.RawSqlite.*;
import sqlite.RawSqlite.RawSqliteStmt;

@:unreflective
class SqliteDatabase extends Finalizable {
    private var db:Pointer<RawSqlite>;
    private var cache = new Map<String, SqliteStatement>();

    public function new(db:Pointer<RawSqlite>) {
        super();
        this.db = db;
    }

    public function close() {
        for (key in cache.keys()) {
            var stmt = cache.get(key);
            stmt.close();
        }
        cache = new Map<String, SqliteStatement>();
        sqlite3_close(db.raw);
        db = null;
    }

    public override function finalize() {
        if (!useStatmentCache) {
            //close();
        }
        super.finalize();
    }

    private var useStatmentCache:Bool = false; // lets keep the cache, but turn it off, may be useful in the future
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
            if (useStatmentCache) {
                cache[sql] = stmt;
            }
        } else {
            stmt.reset();
        }

        return stmt;
    }

    public function lastInsertRowId():Int {
        return sqlite3_last_insert_rowid(db.raw);
    }

    public function changes():Int {
        return sqlite3_changes(db.raw);
    }
}