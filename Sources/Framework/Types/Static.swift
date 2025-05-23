public protocol StaticModule: Module {
 static var shared: Self { get set }
}

@_spi(ModuleReflection)
@Reflection
public extension StaticModule {
 static var state: ModuleState {
  Reflection.cacheIfNeeded(
   id: _mangledName, module: shared, stateType: ModuleState.self
  )
 }

 unowned static var context: ModuleContext { state.context }

 static func callContext() async throws {
  try await context.callAsFunction()
 }

 static func callContext(with state: ModuleContext.State) async throws {
  try await context.callAsFunction(with: state)
 }

 static func cancelContext() async {
  await context.cancel()
 }

 static func cancelContext(with state: ModuleContext.State) async {
  await context.cancel(with: state)
 }

 static func updateContext() async throws {
  try await context.update()
 }

 static func updateContext(with state: ModuleContext.State) async throws {
  try await context.update(with: state)
 }

 static func waitForContext() async throws {
  try await context.wait()
 }

 static func waitForAllOnContext() async throws {
  try await context.waitForAll()
 }
}

public extension StaticModule {
 func callContext() async throws {
  try await Self.callContext()
 }

 func callContext(with state: ModuleContext.State) async throws {
  try await Self.callContext(with: state)
 }

 func cancelContext() async {
  await Self.cancelContext()
 }

 func cancelContext(with state: ModuleContext.State) async {
  await Self.cancelContext(with: state)
 }

 func updateContext() async throws {
  try await Self.updateContext()
 }

 func updateContext(with _: ModuleContext.State) async throws {
  try await Self.updateContext()
 }

 func waitForContext() async throws {
  try await Self.waitForContext()
 }

 func waitForAllOnContext() async throws {
  try await Self.waitForAllOnContext()
 }

 nonisolated func callContext() {
  Task.detached {
   try await Self.callContext()
  }
 }

 nonisolated func callContext(with state: ModuleContext.State) {
  Task.detached {
   try await Self.callContext(with: state)
  }
 }

 nonisolated func cancelContext() {
  Task.detached {
   await Self.cancelContext()
  }
 }

 nonisolated func cancelContext(with state: ModuleContext.State) {
  Task.detached {
   await Self.cancelContext(with: state)
  }
 }

 nonisolated func updateContext() {
  Task.detached {
   try await Self.updateContext()
  }
 }

 nonisolated func updateContext(with state: ModuleContext.State) {
  Task.detached {
   try await Self.updateContext(with: state)
  }
 }

 nonisolated func withContext(
  action: @Reflection @escaping (ModuleContext) async throws -> Void
 ) {
  Task.detached {
   try await action(Self.context)
  }
 }

 nonisolated func withContext(
  action: @Reflection @escaping (ModuleContext) throws -> Void
 ) rethrows {
  Task.detached { @Reflection in
   try action(Self.context)
  }
 }

 @discardableResult
 nonisolated func withContext<A>(
  action: @Reflection @escaping (ModuleContext) async throws -> A
 ) async rethrows -> A {
  try await action(Self.context)
 }

 nonisolated func callWithContext(
  action: @Reflection @escaping (ModuleContext) async throws -> Void
 ) {
  Task.detached { @Reflection in
   defer { self.callContext() }
   return try await action(Self.context)
  }
 }

 @discardableResult
 nonisolated func callWithContext<A>(
  action: @Reflection @escaping (ModuleContext) async throws -> A
 ) async rethrows -> A {
  defer { Task.detached { @Reflection in self.callContext() } }
  return try await action(Self.context)
 }

 nonisolated func callWithContext(
  to state: ModuleContext.State,
  action: @Reflection @escaping (ModuleContext) async throws -> Void
 ) {
  Task.detached { @Reflection in
   defer { self.callContext(with: state) }
   return try await action(Self.context)
  }
 }

 @discardableResult
 func callWithContext<A>(
  to state: ModuleContext.State,
  action: @Reflection @escaping (ModuleContext) async throws -> A
 ) async rethrows -> A {
  defer { self.callContext(with: state) }
  return try await action(Self.context)
 }
}

@Reflection
extension StaticModule {
 @discardableResult
 func withContext<A>(
  action: @Reflection @escaping (ModuleContext) throws -> A
 ) rethrows -> A {
  try action(Self.context)
 }

 func callWithContext(
  action: @Reflection @escaping (ModuleContext) throws -> Void
 ) rethrows {
  defer { self.callContext() }
  try action(Self.context)
 }

 func callWithContext(
  to state: ModuleContext.State,
  action: @Reflection @escaping (ModuleContext) throws -> Void
 ) rethrows {
  defer { self.callContext(with: state) }
  try action(Self.context)
 }
}

#if canImport(Combine) && canImport(SwiftUI)
import Combine

@Reflection
public extension StaticModule {
 var contextWillChange: ModuleContext.ObjectWillChangePublisher {
  Self.context.objectWillChange
 }
}

#elseif os(WASI) && canImport(TokamakCore) && canImport(OpenCombine)
import OpenCombine

@Reflection
public extension StaticModule {
 var contextWillChange: ModuleContext.ObjectWillChangePublisher {
  Self.context.objectWillChange
 }
}
#endif
