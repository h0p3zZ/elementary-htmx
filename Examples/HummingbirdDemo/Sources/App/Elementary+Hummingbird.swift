import Elementary
import Hummingbird

struct HTMLResponse<Content: HTML & Sendable> {
    @HTMLBuilder var content: Content
}

struct HTMLResponseBodyWriter: HTMLStreamWriter {
    func write(_ bytes: ArraySlice<UInt8>) async throws {
        try await writer.write(allocator.buffer(bytes: bytes))
    }

    var allocator: ByteBufferAllocator
    var writer: any ResponseBodyWriter
}

extension HTMLResponse: ResponseGenerator {
    func response(from request: Request, context: some RequestContext) throws -> Response {
        .init(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: .init { writer in
                try await content.render(into: HTMLResponseBodyWriter(allocator: context.allocator, writer: writer))
            }
        )
    }
}
