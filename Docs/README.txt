*** Conditions for run:
It's condition from apple - App and HelperTool should be signed.
1) Build (not run!) FileInfoApp target - app (product) needed for step #3.1
2) Sign: Select your team and check your MacOS Developer certificate it should be downloaded and valid.
2.1) Sign: Use example #2 from "SMJobBlessUtil.txt" for code sign fixing.
3) Clean and Run.

Why it needed?
Project will be buildable anyway, but our app won't connected to HelperTool, because codeSign conditions won't incorrect.
