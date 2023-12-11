import AppKit
import URLSchemer

struct SmallerStringAction: Action {
    let module: URLSchemer.Module
    let subject: String
    let verb: String?

    let object: String?

    let payload: Payload?

    init(
        module: Module,
        subject: String,
        verb: String?,
        object: String? = nil,
        payload: Payload? = nil
    ) {
        self.module = module
        self.subject = subject
        self.verb = verb
        self.object = object
        self.payload = payload
    }

    func lowercased(
        includingObject: Bool = false
    ) -> Self {
        assert(module.rawValue == module.rawValue.lowercased(),
               "Module names are already lowercased for matching")
        return SmallerStringAction(
            module: module,
            subject: subject.lowercased(),
            verb: verb?.lowercased(),
            object: includingObject ? object?.lowercased() : object,
            payload: payload?.lowercased()
        )
    }
}

struct URLComponentsParser: ActionParser {
    @inlinable
    init() { }

    @inlinable
    @inline(__always)
    func parse(_ urlComponents: URLComponents) throws -> SmallerStringAction {
        guard let host = urlComponents.host,
              var pathComponents = urlComponents.pathComponents,
              let subject = pathComponents.popFirst()
        else { throw ActionParsingError.failed }

        let verb = pathComponents.popFirst()
        let object = pathComponents.popFirst()
        let payloadPairs = urlComponents.queryItems?.map { ($0.name, $0.value) }

        return SmallerStringAction(
            module: .init(host),
            subject: subject,
            verb: verb,
            object: object,
            payload: payloadPairs.map(Dictionary.fromKeysAndValuesKeepingLatestValue())
        )
    }
}

final class URLSchemeHandler {
    typealias ParsedStringActionHandler = (SmallerStringAction) -> Void

    typealias ActionParser = (
        _ actionFactory: @escaping (
            _ sink: @escaping ParsedStringActionHandler
        ) throws -> Void
    ) throws -> Void

    let actionParser: ActionParser

    init(
        actionParser: @escaping ActionParser
    ) {
        self.actionParser = actionParser
    }

    @inlinable
    convenience init(
        actionHandler: @escaping ParsedStringActionHandler
    ) {
        self.init(
            actionParser: { actionFactory in
                try actionFactory(actionHandler)
            }
        )
    }

    func install(onEventManager eventManager: NSAppleEventManager = NSAppleEventManager.shared()) {
        eventManager.setEventHandler(
            self,
            andSelector: #selector(URLSchemeHandler.handle(getUrlEvent:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL))
    }

    @objc func handle(
        getUrlEvent event: NSAppleEventDescriptor,
        withReplyEvent replyEvent: NSAppleEventDescriptor
    ) {
        guard let urlComponents = event.urlComponents else { return }
        do {
            try actionParser { sink in
                try URLComponentsParser()
                    .parse(urlComponents)
                    .do(AnySink(base: sink))
            }
        } catch {

        }
    }
}
