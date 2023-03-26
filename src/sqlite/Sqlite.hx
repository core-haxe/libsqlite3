package sqlite;

import cpp.Pointer;
import cpp.RawPointer;
import haxe.Exception;
import sqlite.RawSqlite.*;

// adapted somewhat from: https://github.com/davidgiven/stellation/blob/stellation7/src/runtime/cpp/Sqlite.hx

@:buildXml('
    <set name="lib_folder" value="${haxelib:libsqlite3}/lib" />
    <echo value="Using sqlite3 from: ${lib_folder}" />
    <section>
        <files id="haxe">
            <compilerflag value="-I${lib_folder}" />
            <file name="${lib_folder}/sqlite3.c" />
        </files>
    </section>
')
@:unreflective
class Sqlite {
    public static final DONE:Int = untyped __cpp__("SQLITE_DONE");
    public static final ROW:Int = untyped __cpp__("SQLITE_ROW");
    public static final OK:Int = untyped __cpp__("SQLITE_OK");

    public static final INTEGER:Int = untyped __cpp__("SQLITE_INTEGER");
    public static final FLOAT:Int = untyped __cpp__("SQLITE_FLOAT");
    public static final BLOB:Int = untyped __cpp__("SQLITE_BLOB");
    public static final NULL:Int = untyped __cpp__("SQLITE_NULL");
    public static final TEXT:Int = untyped __cpp__("SQLITE_TEXT");

    public static function open(path:String):SqliteDatabase {
        var db:RawPointer<RawSqlite> = null;
        var i = sqlite3_open(path, RawPointer.addressOf(db));
        if (i != 0) {
            throw new Exception(sqlite3_errmsg(db));
        }
        return new SqliteDatabase(Pointer.fromRaw(db));
    }
}