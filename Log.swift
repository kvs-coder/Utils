enum Level: String {
    case info
    case debug
    case warning
    case error
}

func logDebug(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
    #if DEBUG
    log(
        message: message,
        level: .debug,
        file: file,
        line: line,
        function: function
    )
    #endif
}

func logInfo(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
    log(
        message: message,
        level: .info,
        file: file,
        line: line,
        function: function
    )
}

func logError(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
    log(
        message: message,
        level: .error,
        file: file,
        line: line,
        function: function
    )
}

private func log(
    message: String,
    level: Level,
    file: String,
    line: Int,
    function: String
) {
    let logLevel = level.rawValue.uppercased()
    let logTime = Date()
    let place = (file as NSString).lastPathComponent
    print("[\(logLevel) - \(logTime)]: [\(place):\(line) - \(function)]\n \(message)")
}