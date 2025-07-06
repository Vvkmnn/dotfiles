# Debug Workflow

Analyze issue systematically:

1. **Examine Error Context**
   - Read full error messages and stack traces
   - Check relevant log files
   - Identify the exact failure point

2. **Code Investigation**
   - Review the failing code section
   - Check recent changes with git log
   - Examine related functions and dependencies

3. **Root Cause Analysis**
   - Trace the issue to its source
   - Identify why the error occurred
   - Consider edge cases and error conditions

4. **Implement Fix**
   - Create targeted solution
   - Test the fix thoroughly
   - Ensure no regressions introduced

5. **Verification**
   - Run full test suite
   - Verify fix works in different scenarios
   - Document the solution for future reference