import com.intuit.karate.junit5.Karate;

public class RunXYZBankOps {
    @Karate.Test
    Karate runXyzBankOps() {
        return Karate.run("XYZBankOps").relativeTo(getClass());
    }
}







