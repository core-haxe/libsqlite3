package;

import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;

class TestAll {
    public static function main() {
        var runner = new Runner();
        
        runner.addCase(new TestQuery());
        runner.addCase(new TestPreparedQuery());
        runner.addCase(new TestInsert());
        runner.addCase(new TestPreparedInsert());
        runner.addCase(new TestInnerJoin());
        runner.addCase(new TestPreparedInnerJoin());
        runner.addCase(new TestBlob());
        runner.addCase(new TestPreparedBlob());

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }
}