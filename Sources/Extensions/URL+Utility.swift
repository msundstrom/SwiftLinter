
import Foundation

extension URL {
    func reduce(_ url: URL) -> String {
        return url.path.replacingOccurrences(of: self.path, with: "")
    }

    func isFiltered(by linters: [FileIgnore]) -> Bool {
        for ignore in linters {
            if ignore.shouldExclude(self) {
                return true
            }
        }

        return false
    }
}
