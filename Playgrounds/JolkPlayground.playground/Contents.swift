import JolkCore

let executableURL = URL(fileURLWithPath: "/usr/libexec/remotectl")
let output = AnalysisOutput.create(for: executableURL)

let dynamicLinkerAnalyzer = DynamicLinkerAnalyzer()
try dynamicLinkerAnalyzer.analyze(executableURL, output)
let linkedFrameworks = output.get("dynamic-linker.linked-frameworks").value as! [String]
print(linkedFrameworks)
