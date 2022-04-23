import Foundation

func print(_ items: Any...) {
    #if DEBUG
        Swift.print(items[0])
    #endif
}
