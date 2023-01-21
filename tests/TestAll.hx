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
        runner.addCase(new TestInnerJoin());
        runner.addCase(new TestPreparedInnerJoin());

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }
}