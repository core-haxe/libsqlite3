package sqlite;

import cpp.ConstPointer;
import cpp.UInt8;
import cpp.RawConstPointer;
import cpp.NativeArray;
import haxe.io.BytesData;
import haxe.io.Bytes;
import haxe.Exception;
import cpp.Pointer;
import cpp.Finalizable;
import sqlite.RawSqlite.*;
import sqlite.RawSqlite.RawSqliteStmt;
import haxe.ds.Vector;

@:unreflective
class SqliteStatement extends Finalizable {
    private var db:Pointer<RawSqlite>;
    private var stmt:Pointer<RawSqliteStmt>;

    public function new(db:Pointer<RawSqlite>, stmt:Pointer<RawSqliteStmt>) {
        super();
        this.db = db;
        this.stmt = stmt;
    }

    public override function finalize() {
        close();
        super.finalize();
    }

    public function close() {
        sqlite3_finalize(stmt.raw);
        this.db = null;
        this.stmt = null;
    }

    public function reset():SqliteStatement {
        sqlite3_reset(stmt.raw);
        return this;
    }

    public function bindInt(index:Int, value:Int):SqliteStatement {
        untyped __cpp__("sqlite3_bind_int({0}, {1}, {2})", stmt, index, value);
        return this;
    }

    public function bindFloat(index:Int, value:Float):SqliteStatement {
        untyped __cpp__("sqlite3_bind_double({0}, {1}, {2})", stmt, index, value);
        return this;
    }

    public function bindString(index:Int, value:String):SqliteStatement {
        untyped __cpp__("sqlite3_bind_text({0}, {1}, {2}, -1, SQLITE_TRANSIENT)", stmt, index, value);
        return this;
    }

    public function bindBytes(index:Int, value:Bytes):SqliteStatement {
        var len = value.length;
        var p = NativeArray.address(value.getData(), 0);
        untyped __cpp__("sqlite3_bind_blob({0}, {1}, {2}, {3}, SQLITE_TRANSIENT)", stmt, index, p, len);
        return this;
    }

    public function executeStatement() {
        var i = sqlite3_step(stmt.raw);
        if (i != Sqlite.DONE) {
            throw new Exception(sqlite3_errmsg(db.raw));
        }
    }

    public function executeQuery():Iterator<Dynamic> {
        var columnCount = sqlite3_column_count(stmt.raw);
        var columnNames = new Vector<String>(columnCount);
        for (i in 0...columnCount) {
            columnNames[i] = sqlite3_column_name(stmt.raw, i);
        }

        var status = sqlite3_step(stmt.raw);

        return {
            hasNext: () -> status == Sqlite.ROW,
            next: () -> {
                switch (status) {
                    case Sqlite.DONE:
                        return null;
                    case Sqlite.ROW:
                        var data = {};
                        for (i in 0...columnCount) {
                            var type = sqlite3_column_type(stmt.raw, i);
                            switch (type) {
                                case Sqlite.INTEGER:
                                    Reflect.setField(data, columnNames[i], sqlite3_column_int(stmt.raw, i));
                                case Sqlite.FLOAT:    
                                    Reflect.setField(data, columnNames[i], sqlite3_column_double(stmt.raw, i));
                                case Sqlite.TEXT:
                                    var s:String = untyped __cpp__("(const char*)sqlite3_column_text({0}, {1})", stmt.raw, i);
                                    Reflect.setField(data, columnNames[i], s);
                                case Sqlite.BLOB:
                                    var rawData:RawConstPointer<cpp.Void> = sqlite3_column_blob(stmt.raw, i);
                                    var p:ConstPointer<cpp.Void> = ConstPointer.fromRaw(rawData);
                                    var size:Int = sqlite3_column_bytes(stmt.raw, i);
                                    var bytesData:Array<UInt8> = NativeArray.create(size);
                                    NativeArray.setData(bytesData, p.reinterpret(), size);
                                    var bytes:Bytes = Bytes.ofData(bytesData);
                                    var bytesCopy:Bytes = Bytes.alloc(size); // need to maybe a copy, gc'd or freed maybe?
                                    bytesCopy.blit(0, bytes, 0, size);
                                    Reflect.setField(data, columnNames[i], bytesCopy);
                                case Sqlite.NULL:
                                    Reflect.setField(data, columnNames[i], null);
                                case _:
                                    throw new Exception('Type error ${type}');               
                            }
                        }
                        status = sqlite3_step(stmt.raw);
                        return data;
                    case _:
                        throw new Exception('Cursor error ${status}');
                }
            }
        }
    }
}