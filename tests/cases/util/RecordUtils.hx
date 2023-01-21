package cases.util;

class RecordUtils {
    public static function toArray(it:Iterator<Dynamic>) {
        var rs = [];
        while (it.hasNext()) {
            rs.push(it.next());
        }
        return rs;
    }
}