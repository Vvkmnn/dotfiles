#!/usr/bin/swift
//
//  WindowNavigator.swift
//  Window Navigator Alfred Workflow
//  v2.1.0
//
//  Navigate to any window of the active app across all desktops,
//  Globally navigate to any window open on any desktop space, or
//  Switch windows open within the current desktop space.
//
//
//  Created by Patrick Sy on 21/05/2024.
//  Refactored by Patrick Sy on 04/04/2025.
//  <https://github.com/zeitlings/alfred-workflows>
//

import ApplicationServices

// MARK: - WindowNavigator
struct WindowNavigator {

	// MARK: Navigator Configuration
	struct Configuration {
		let cacheDuration: TimeInterval
		let frontMostApplicationName: String?
		let directive: Directive
		let query: String?

		static let standard: Configuration = .init(
			cacheDuration: Environment.cacheLifetime,
			frontMostApplicationName: NSWorkspace.shared.frontmostApplication?.localizedName,
			directive: Directive(rawValue: CommandLine.arguments[safe: 1] ?? "global") ?? .global,
			query: {
				guard CommandLine.arguments.indices.contains(2) else { return nil }
				let query: String = CommandLine.arguments[2].trimmed
				return query.isEmpty ? nil : query
			}()
		)
	}

	// Core properties
	static let config = Configuration.standard
	static var runningApplications: [NSRunningApplication]? = NSWorkspace.shared.runningApplications.deduplicated()
	static var registeredExceptions: [(bundleID: String, window: WindowWrapper)] = []
	static var windowMenuStates: [String: WindowMenuRepresentation] = [:]
	static var windowCandidateNames: Set<String>?
	private static let stdOut: FileHandle = .standardOutput

	// Core
	static func run() async {
		defer { runningApplications = nil }
		Caching.returnWindows(filter: config.query)
		windowCandidateNames = await windowCandidates()

		var items: [Item]
		switch config.directive {
		case .navigator: items = windowsRelative.map({ $0.alfredItem })
		case .switcher:  items = windowsOnScreen.map({ $0.alfredItem })
		case .global:    items = windowsGlobally.map({ $0.alfredItem })
		}

		handle(&items, for: registeredExceptions)
		handle(&items, for: config.query)
		Self.return(items: items, save: true)
	}

}


// MARK: Inflatable Protocol
protocol Inflatable {
	init()
}

extension Inflatable {
	static func with(_ populator: (inout Self) throws -> Void) rethrows -> Self {
		var instance = Self()
		try populator(&instance)
		return instance
	}
}


// MARK: Actor Collector
actor MenuCollector {
	var falsePositives: Set<String> = []
	var windowStates: [String: WindowMenuRepresentation] = [:]

	func add(states: Set<WindowMenuRepresentation>, frauds: Set<String>) {
		for state in states {
			windowStates[state.name] = state
		}
		self.falsePositives.formUnion(frauds)
	}
}

// MARK: - Directive
enum Directive: String, Codable {
	case navigator
	case switcher
	case global

	var noWindowDescription: String {
		switch WindowNavigator.config.directive {
		case .navigator:
			if let appName: String = WindowNavigator.config.frontMostApplicationName {
				return "Ensure at least one other \(appName) window is visible in any desktop space."
			}
			return "Ensure at least one window is visible in the current desktop space."
		case .switcher:
			return Environment.includeFrontmostWindow
			? "Ensure at least one window is visible in the current desktop space."
			: "Ensure at least one other window is visible in the current desktop space."
		case .global:
			return "Ensure at least one window is visible in any desktop space."
		}
	}

	// For external trigger reentry
	var reentryIdentifier: String {
		switch self {
		case .navigator: return "reentry_navigator"
		case .switcher: return "reentry_switcher"
		case .global: return "reentry_global"
		}
	}
}

// MARK: Window Menu Representation
struct WindowMenuRepresentation: Hashable {
	let name: String
	let isActive: Bool
	let isMinimized: Bool
}


// MARK: - Accessibility Operations
extension WindowNavigator {

	struct AX {
		// MARK: AX: Raise Window
		static func raise(
			applicationPID: Int32 = Environment.applicationPID,
			windowNumber: Int32 = Environment.windowNumber,
			windowName: String = Environment.windowName
		) async -> Never {

			// Special case handling: assert only one window can exist for this case
			if Environment.presentsSpecialCase,
			   let bundleID: String = Environment.specialCaseBundleID,
			   let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first
			   //let app = NSRunningApplication(processIdentifier: pid_t(applicationPID))
			{
				app.activate(options: .activateAllWindows)
				exit(.success)
			}

			let axApp: AXUIElement = AXUIElementCreateApplication(pid_t(applicationPID))
			if let axWindow: AXUIElement = axApp.windowWithinCurrentDesktopSpace(windowNumber: windowNumber) {
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate()
				AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
			} else {
				guard let menuBar: AXUIElement = axApp.getAttribute(named: kAXMenuBarAttribute),
					  let targetWindowRep: AXUIElement = menuBar.firstMenuBarItem(named: windowName)
				else {
					Environment.log("[Warning] Failure retrieving menu bar item representation of window with name <\(windowName)>")
					exit(.success)
				}
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate()
				targetWindowRep.press()
			}
			exit(.success)
		}

		// MARK: AX: Close Window
		static func close(
			applicationPID: Int32 = Environment.applicationPID,
			windowNumber: Int32 = Environment.windowNumber,
			windowName: String = Environment.windowName
		) async -> Never {

			func cleanUp(line: Int = #line) {
				typealias CacheWrapper = WindowNavigator.Caching.CacheWrapper
				if let globalCache: CacheWrapper = Caching.getResponse(with: .global)?.0 {
					var response: Response = globalCache.response
					if let pos: Int = response.items.firstIndex(where: { $0.title == windowName }) {
						response.items.remove(at: pos)
						_ = response.encoded(save: true, directive: .global)
					} else {
					}
				}

				// Remove item from local cache
				if let caches: [CacheWrapper] = Caching.getResponse(with: .navigator)?.1,
				   let appName: String = Environment.owningApplicationName,
				   let local: CacheWrapper = caches.first(where: { $0.frontmostApplication == appName })
				{
					var response: Response = local.response
					if let pos: Int = response.items.firstIndex(where: { $0.title == windowName }) {
						response.items.remove(at: pos)
						_ = response.encoded(save: true, directive: .navigator, frontmost: appName)
					}
				}
			}

			// Special case handling
			if Environment.presentsSpecialCase {
				// Save current frontmost application to return to later
				let previousFrontmost: NSRunningApplication? = NSWorkspace.shared.frontmostApplication

				// Activate the target application
				if let app = NSRunningApplication(processIdentifier: pid_t(applicationPID)) {
					app.activate(options: .activateAllWindows)

					try? await Task.sleep(for: .milliseconds(500))
					//RunLoop.current.run(until: Date.now + TimeInterval(0.5))

					// Get the window now present in the current desktop space
					let axApp = AXUIElementCreateApplication(applicationPID)
					if let axWindow: AXUIElement = axApp.windowWithinCurrentDesktopSpace(windowNumber: windowNumber),
					   let closeButton: AXUIElement = axWindow.getAttribute(named: kAXCloseButtonAttribute)
					{
						closeButton.press()
						try? await Task.sleep(for: .milliseconds(300))
						//RunLoop.current.run(until: Date.now + TimeInterval(0.3))
						previousFrontmost?.activate(options: .activateAllWindows)
						try? await Task.sleep(for: .milliseconds(500))

						cleanUp()
						exit(.success)
					}

				}
				// If we get here, we couldn't find a close button, but still exit
				// since we tried our best with a special case app
				Environment.log("[Info] Could not find close button for special case app")
				previousFrontmost?.activate()
				exit(.success)
			}


			let axApp: AXUIElement = AXUIElementCreateApplication(pid_t(applicationPID))
			if let axWindow: AXUIElement = axApp.windowWithinCurrentDesktopSpace(windowNumber: windowNumber),
			   let closeButton: AXUIElement = axWindow.getAttribute(named: kAXCloseButtonAttribute)
			{
				closeButton.press()
			} else {

				guard let targetMenuBar: AXUIElement = axApp.getAttribute(named: kAXMenuBarAttribute) else {
					Environment.log("[Warning] Failure retrieving menu bar of application with PID <\(applicationPID)>")
					exit(.failure)
				}

				guard let targetWindowMenuBarRep: AXUIElement = targetMenuBar.firstMenuBarItem(named: windowName) else {
					Environment.log("[Warning] Failure retrieving menu bar item representation of window with name <\(windowName)>")
					exit(.failure)
				}

				let frontmost: NSRunningApplication? = NSWorkspace.shared.frontmostApplication
				let originAXAppBackup: AXUIElement? = {
					if let frontmost: NSRunningApplication {
						return AXUIElementCreateApplication(frontmost.processIdentifier)
					}
					return nil
				}()
				let originMenuBar: AXUIElement? = originAXAppBackup?.getAttribute(named: kAXMenuBarAttribute)

				/// Get the  menu bar item representing the currently active window.
				/// The currently active window is decorated with a check mark which can be retrieved using the `kAXMenuItemMarkCharAttribute` key.
				let originWindowMenuBarRep: AXUIElement? = originMenuBar?.firstMenuBarItem(where: { $0.isActiveWindowRepresentation })

				/// In some cases the `originWindowMenuBarRep` element becomes invalid after closing the target window.
				/// This may be related to its position in the menu bar list. To compensate for this eventuality, we retrieve a new version of it.
				let originWindowMenuBarRepName: String? = originWindowMenuBarRep?.name

				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate()
				targetWindowMenuBarRep.press()
				try? await Task.sleep(for: .milliseconds(500))
				//RunLoop.current.run(until: Date.now + TimeInterval(0.5))

				/// Now we are on the desktop space that contains the window we want to close
				/// We assert that the axWindow can now be matched given the window number
				guard let targetAXWindow: AXUIElement = axApp.windowWithinCurrentDesktopSpace(windowNumber: windowNumber),
					  let closeButton: AXUIElement = targetAXWindow.getAttribute(named: kAXCloseButtonAttribute)
				else {
					Environment.log("[Error] Unable to obtain axWindow with name '\(windowName)' and number '\(windowNumber)'")
					exit(.failure)
				}
				// Close the target window
				closeButton.press()

				// Return to the previously focused window if it exists.
				if let originWindowMenuBarRep: AXUIElement {
					frontmost?.activate()
					// Required where the owning app of the closed window is the frontmost app
					if !originWindowMenuBarRep.press(),
					   let originWindowMenuBarRepName: String,
					   let originWindowMenuBarRepRestored: AXUIElement = originAXAppBackup?.firstMenuBarItem(named: originWindowMenuBarRepName)
					{
						originWindowMenuBarRepRestored.press()
					}
				}
			}
			try? await Task.sleep(for: .milliseconds(300))
			cleanUp()
			exit(.success)
		}
	}
}

// MARK: - Caching Operations
extension WindowNavigator {

	struct Caching {

		// MARK: CacheWrapper
		struct CacheWrapper: Codable {
			let directive: Directive
			let frontmostApplication: String
			let timestamp: Date
			let response: Response

			var isStale: Bool {
				Date().timeIntervalSince(timestamp) > WindowNavigator.config.cacheDuration
			}
		}

		@discardableResult
		static func returnWindows(filter query: String?, fm: FileManager = .default) -> Never? {
			guard config.directive != .switcher else { return nil }
			guard (!Environment.cacheFeedbackGiven || Caching.hasChanged(query: query)) else { return nil }
			guard fm.fileExists(atPath: Environment.cacheFile.path) else { return nil }

			Caching.remember(query: query)
			// Keeping the force refresh for now although we're cleaning up at AX close
			// There are some cache and rerun timing issues that are not worth the effort
			// As we're gaining just gaining a few milliseconds.
			let forceRefresh: Bool = Caching.signalsForceRefresh()

			if query != nil && forceRefresh && config.directive == .navigator {
				// Consider the extraneous item that lingers for half a second
				// not be a problen in the global window list, but refresh right
				// away if we're focusing via a query or are focused on an
				// application due to the navigator directive.
				return nil
			}

			if let (cached, caches) = getResponse(with: config.directive) {
				let vars: [String:String] = ["cache_feedback_given": "true", "reentry_argument": query ?? ""]
				let variables = cached.response.variables?.merging(vars) { _, new in new }
				var response: Response = .init(items: cached.response.items, rerun: 0.1, variables: variables)
				assure(items: &response.items, for: config.directive, cache: cached, caches: caches) // FIXME: Sic!?
				handle(query: query, response: &response, refresh: forceRefresh)
				response.items.isEmpty
					? WindowNavigator.return(items: [.noWindows], save: config.directive == .navigator)
					: WindowNavigator.return(response, save: false)
				exit(.success)
			}

			return nil
		}

		static func remember(query: String?) {
			guard let query else { return }
			try? query.write(toFile: Environment.queryMemoryFile.path, atomically: true, encoding: .utf8)
		}

		static func hasChanged(query: String?, fm: FileManager = .default) -> Bool {
			guard let previous: String = try? String(contentsOfFile: Environment.queryMemoryFile.path) else {
				return false
			}
			guard let query else { return trueClearingMemory() }
			return previous != query
		}

		static private func trueClearingMemory(fm: FileManager = .default) -> Bool {
			removeMemoryFile()
			return true
		}

		// TODO: ROLL BACK
		static func removeMemoryFile(fm: FileManager = .default) {
			try? fm.removeItem(atPath: Environment.queryMemoryFile.path)
		}

		static func signalsForceRefresh(fm: FileManager = .default) -> Bool {
			guard fm.fileExists(atPath: Environment.forceRefreshFile.path) else {
				return false
			}
			try? fm.removeItem(at: Environment.forceRefreshFile)
			return true
		}

		static func getResponse(with directive: Directive, fm: FileManager = .default) -> (CacheWrapper, [CacheWrapper])? {
			if let cached: Data = fm.contents(atPath: Environment.cacheFile.path),
			   let wrapper: [CacheWrapper] = try? JSONDecoder().decode([CacheWrapper].self, from: cached),
			   let cached: CacheWrapper = wrapper.first(where: { $0.directive == directive })
			{
				return cached.isStale ? nil : (cached, wrapper)
			}
			return nil
		}

		static private func assure(items: inout [Item], for directive: Directive, cache: CacheWrapper, caches: [CacheWrapper]) {
			if let frontmost: String = WindowNavigator.config.frontMostApplicationName,
			   cache.frontmostApplication != frontmost,
			   directive == .navigator,
			   let global: CacheWrapper = caches.first(where: { $0.directive == .global })
			{
				let replacement: [Item] = global.response.items.filter({ $0.subtitle == frontmost })
				items = replacement
			}
		}

		@discardableResult
		static private func handle(query: String?, response: inout Response, refresh forceRefresh: Bool) -> Never? {
			if let query: String {
				let components: [Substring] = query.split(separator: " ")
				let items: [Item] = response.items.filter({
					item in components.allSatisfy({ item.match.hasSubstring($0) })
				})
				response.items = items
				response.rerun = nil

				if response.items.isEmpty {
					let response = Response(items: [.noResults], rerun: 0.1, variables: ["cache_feedback_given": "true"])
					WindowNavigator.return(response, save: false)
				} else {
					response.rerun = forceRefresh ? 0.1 : nil
					WindowNavigator.return(response, save: false)
				}
				exit(.success)
			}

			return nil
		}
	}


}

// MARK: - Exception Handling
extension WindowNavigator {

	static let knownExceptions: [String:String] = ["Claude": "com.anthropic.claudefordesktop"]

	static func registerException(for window: WindowWrapper, exceptions: [String:String] = knownExceptions) {
		if let bundleIdentifier: String = exceptions[window.owningApplicationName] {
			Self.registeredExceptions.append((bundleID: bundleIdentifier, window: window))
		}
	}

	static func handle(_ items: inout [Item], for exceptions: [(bundleID: String, window: WindowWrapper)]) {
		for exception in exceptions
		where items.first(where: { $0.subtitle == exception.window.owningApplicationName }) == nil
		// Failsafe in case the app architecture changes at some point and we find already included windows
		{
			var item: Item = exception.window.alfredItem
			item.variables?["special_case"] = "yes"
			item.variables?["owner"] = exception.bundleID
			items.insert(item, at: 0)
		}
	}
}

// MARK: - Query Handling
extension WindowNavigator {

	@discardableResult
	static func handle(_ items: inout [Item], for query: String?) -> Never? {
		guard let query: String = query?.trimmed, !query.isEmpty else {
			return nil
		}
		var response: Response = .init(items: items)
		_ = response.encoded(save: true) // Cache the full response regardless of the query
		let components: [Substring] = query.split(separator: " ")
		let items: [Item] = response.items.filter({ item in components.allSatisfy({ item.match.hasSubstring($0) }) })
		response.items = items
		if response.items.isEmpty {
			WindowNavigator.return(items: [.noResults], save: false)
		} else {
			WindowNavigator.return(response, save: false)
		}
		exit(.success)
	}

}


// MARK: - WindowNavigator Window Processing
extension WindowNavigator {
	static func windowCandidates() async -> Set<String> {
		guard config.directive != .switcher else {
			return []
		}

		guard let runningApplications: [NSRunningApplication] = runningApplications else {
			preconditionFailure("Unable to retrieve running applications.")
		}
		let collector: MenuCollector = .init()
		await withTaskGroup(of: Void.self) { group in
			for application in runningApplications {
				group.addTask {
					let (windowCandidateInfo, fraudulentApps) = await processApplication(application)
					await collector.add(states: windowCandidateInfo, frauds: fraudulentApps)
				}
			}
		}

		let finalFrauds: Set<String> = await collector.falsePositives
		if !finalFrauds.isEmpty {
			let count: Int = finalFrauds.count
			let message: String = "Remembering \(count) new \(count == 1 ? "process" : "processes") to ignore."
			Environment.log(message)
			remember(frauds: finalFrauds)
		}

		Self.windowMenuStates = await collector.windowStates
		return await Set(collector.windowStates.keys)
	}


	static func processApplication(_ application: NSRunningApplication) async -> (Set<WindowMenuRepresentation>, Set<String>) {
		guard let applicationName: String = application.localizedName else {
			Environment.log("[Warning] Application with PID <\(application.processIdentifier)> has no localized name")
			return ([], [])
		}

		guard !knownFrauds.contains(applicationName),
			  !knownFraudsSharedPrefixes.anySatisfy({ applicationName.hasPrefix($0) }),
			  !knownFraudsSharedSuffixes.anySatisfy({ applicationName.hasSuffix($0) })
		else {
			return ([], [])
		}

		// Menubar item names that may represent a window
		var windowCandidates: Set<WindowMenuRepresentation> = []
		var appFrauds: Set<String> = []

		let axApp: AXUIElement = AXUIElementCreateApplication(application.processIdentifier)
		guard let targetMenuBar: AXUIElement = axApp.menunBar else {
			Environment.log("[Info] Could not retrieve menu bar of application with name <\(application.localizedName ?? "Unknown")> PID <\(application.processIdentifier)>")
			if let appName: String = application.localizedName {
				appFrauds.insert(appName)
			}
			return ([], appFrauds)
		}

		if let menuItems: [AXUIElement] = targetMenuBar.children {
			// Process menu items for this application
			for menuItem: AXUIElement in menuItems.reversed() {
				guard localizedWindowMenubarNames.contains(menuItem.name ?? "") else {
					continue
				}
				if let extraElement: AXUIElement = menuItem.children?.first,
				   let menuBarItems: [AXUIElement] = extraElement.children
				{
					for item in menuBarItems {
						guard let name = item.name?.droppingSuffix("Edited"), !name.isEmpty else { continue }

						// ActiveWindowRepresentation seems to only catch xcode windows—when focused.
						// Also fails for non-exact representations, i.e. — Edited
						//let isActive = item.isActiveWindowRepresentation
						let isActive = false
						let isMinimized = item.isMinimizedWindowRepresentation

						windowCandidates.insert(WindowMenuRepresentation(name: name, isActive: isActive, isMinimized: isMinimized))
					}
				}
			}
		}

		return (windowCandidates, appFrauds)
	}

	// MARK: False Positive Handling
	static let knownFrauds: Set<String> = .observedFrauds()

	static let knownFraudsSharedPrefixes: Set<String> = [
		"QLPreviewGenerationExtension", "Open and Save Panel Service",
		"QuickLookUIService", // e.g. 'QuickLookUIService (Open and Save Panel Service (Xcode))'
		"LookupViewService","Apparency (","Dock Extra",	"ThemeWidgetControlViewService",
		"LocalAuthenticationRemoteService", "WritingToolsViewService", "Writing Tools"
	]

	static let knownFraudsSharedSuffixes: Set<String> = [
		"Networking", "Update Assistant", "Web Content",
		"Quick Look Extension (Finder)", "XPC", "(Plugin)",
		"Helper", "Graphics and Media", "(System Settings)",
		"WidgetExtension", "(System Settings))"
	]

	static let localizedWindowMenubarNames: Set<String> = [
		"Window", 	 // English
		"Fenster", 	 // German
		"Ventana", 	 // Spanish
		"Fenêtre", 	 // French
		"Finestra",  // Italian
		"Janela", 	 // Portuguese
		"ウィンドウ",  // Japanese
		"窗口", 		 // Chinese (Simplified)
		"視窗", 		 // Chinese (Traditional)
		"윈도우", 	 // Korean
		"Окно", 	 // Russian
		"Fönster", 	 // Swedish
		"Vindue", 	 // Danish
		"Vindu", 	 // Norwegian
		"Venster", 	 // Dutch
		"Ikkuna", 	 // Finnish
		"Ablak", 	 // Hungarian
		"Pencere", 	 // Turkish
		"Okno", 	 // Polish
		"Fereastră", // Romanian
		"Prozor", 	 // Croatian
		"Okno", 	 // Czech
		"Okno", 	 // Slovak
		"Παράθυρο",  // Greek
		"חלון", 		 // Hebrew
		"نافذة", 	 // Arabic
		"پنجره", 	 // Persian
		"หน้าต่าง", 	 // Thai
		"Cửa sổ", 	 // Vietnamese
	]

	static func remember(frauds: Set<String>, fm: FileManager = .default) {
		let file: URL = Environment.runtimeFraudsFile
		if !fm.fileExists(atPath: file.path) {
			do {
				try fm.createDirectory(at: Environment.dataFolder, withIntermediateDirectories: true)
			} catch {
				Environment.log("[Warning] Failed to create data folder: \(error)")
				return
			}
		}
		let message: String = frauds.joined(separator: "\n")
		let data: Data = Data("\(message)\n".utf8)
		if let fileHandle = try? FileHandle(forWritingTo: file) {
			fileHandle.seekToEndOfFile()
			fileHandle.write(data)
			fileHandle.closeFile()
		} else {
			try? data.write(to: file, options: .atomicWrite)
		}
	}

}


// MARK: - WindowNavigator Window Collections
extension WindowNavigator {

	/// A list of `WindowWrapper` objects representing all on-screen windows.
	///
	/// This property retrieves information about all on-screen windows, excluding desktop elements,
	/// and converts them into an array of `WindowWrapper` objects. If the window list cannot be retrieved,
	/// the application will terminate with a precondition failure.
	///
	/// - Returns: An array of `WindowWrapper` objects representing the on-screen windows.
	private static let windowsOnScreen: [WindowWrapper] = {
		let onScreenWindowList: CFArray? = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
		guard let onScreenWindows = onScreenWindowList as? [[String: Any]] else {
			preconditionFailure("Unable to retrieve on-screen window list")
		}
		let windows: [WindowWrapper] = onScreenWindows.compactMap({ WindowWrapper($0) })

		switch config.directive {
		case .navigator: return windows
		case .switcher:  return (Environment.includeFrontmostWindow ? windows : .init(windows.dropFirst())).sorted(by: { $0.owningApplicationPID < $1.owningApplicationPID })
		case .global: return windows.first != nil ? [windows.first!] : []
		}
	}()

	/// A list of `WindowWrapper` objects representing alll windows relative to the frontmost active window.
	///
	/// This property retrieves a list of windows related to the frontmost active window, filtering
	/// them based on their process identifier (PID) to include only those belonging to the same
	/// application. It optionally includes the frontmost window itself based on the environment setting.
	///
	/// - Returns: An array of `WindowWrapper` objects representing the windows relative to the frontmost active window.
	private static let windowsRelative: [WindowWrapper] = {
		guard let frontMost: WindowWrapper = windowsOnScreen.first(where: { $0.windowIsOnScreen }) else {
			Self.return(items: [.noWindows], save: false)
		}

		let frontMostApplicationWindowID: CGWindowID = CGWindowID(frontMost.windowNumber)
		let frontMostApplicationPID: Int32 = frontMost.owningApplicationPID

		// Matching the PID of the owning application works for some reason and results in the active window being included.
		let relativeWindowList: CFArray? = Environment.includeFrontmostWindow
		? CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], CGWindowID(frontMostApplicationPID))
		: CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], frontMostApplicationWindowID)

		guard let relativeWindows = relativeWindowList as? [[String: Any]] else {
			preconditionFailure("Unable to retrieve global window list of frontmost on-screen application")
		}

		var windows: [WindowWrapper] = relativeWindows.lazy
			.compactMap({ .init($0) })
			.filter({ $0.owningApplicationPID == frontMostApplicationPID })
			.deduplicated()

		var filteredWindows: [WindowWrapper] = []
		for window in windows {
			if window.isValidWindow {
				filteredWindows.append(window)
			} else {
				Self.registerException(for: window)
			}
		}
		windows = filteredWindows

		return windows.sorted(by: { $0.owningApplicationPID < $1.owningApplicationPID })
	}()

	private static let windowsGlobally: [WindowWrapper] = {
		let globalWindowList: CFArray? = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID)
		guard let allWindows = globalWindowList as? [[String: Any]] else {
			preconditionFailure("Unable to retrieve global window list")
		}

		var windows: [WindowWrapper] = allWindows
			.compactMap({ .init($0) })
			.deduplicated()

		var filteredWindows: [WindowWrapper] = []
		for window in windows {
			if window.isValidWindow {
				filteredWindows.append(window)
			} else {
				Self.registerException(for: window)
			}
		}
		windows = filteredWindows


		if !Environment.includeFrontmostWindow,
		   let first: WindowWrapper = windowsOnScreen.first,
		   let index: Int = windows.firstIndex(where: { $0.windowNumber == first.windowNumber })
		{
			windows.remove(at: index)
		}
		return windows.sorted(by: { $0.owningApplicationPID < $1.owningApplicationPID })
	}()
}

// MARK: - WindowNavigator Utilities
extension WindowNavigator {

	enum ExitCode { case success, failure }
	static func exit(_ code: ExitCode) -> Never {
		switch code {
		case .success: Darwin.exit(EXIT_SUCCESS)
		case .failure: Darwin.exit(EXIT_FAILURE)
		}
	}

	/// Outputs the given items as an Alfred script filter response and terminates the program.
	///
	/// - Parameters:
	///   - items: An array of `Item` objects to be included in the response.
	private static func `return`(items: [Item], save saveCache: Bool) -> Never {
		if items.isEmpty {
			try? stdOut.write(contentsOf: Response(items: [.noWindows]).encoded(save: false))
		} else {
			try? stdOut.write(contentsOf: Response(items: items).encoded(save: saveCache))
		}
		exit(.success)
	}

	private static func `return`(_ response: Response, save: Bool) -> Never {
		try? stdOut.write(contentsOf: response.encoded(save: save))
		exit(.success)
	}

	/// Verifies screen capture access for the application and requests access if necessary.
	///
	/// - Returns: `nil` if screen capture access is already granted. If access is not granted,
	///   the function requests access and terminates the program, thus it does not return in this case.
	@discardableResult
	static func permissions() -> Never? {
		guard CGPreflightScreenCaptureAccess() else {
			CGRequestScreenCaptureAccess()
			exit(.success)
		}
		return nil
	}
}

// MARK: - Core Models

// MARK: WindowWrapper
struct WindowWrapper: CustomDebugStringConvertible, Hashable {
	let owningApplicationName: String
	let owningApplicationPID: Int32
	let applicationPath: String
	let windowTitle: String
	let windowNumber: Int32
	let windowLayer: Int
	let windowAlpha: CGFloat
	let windowBounds: NSRect
	let windowIsOnScreen: Bool
	let windowBackingType: WindowBackingType
	let windowSharingState: WindowSharingState
	let windowMemoryUsage: Double

	let isActiveWindow: Bool
	let isMinimizedWindow: Bool

	init?(_ info: [String : Any]) {
		guard
			let owningApplicationName = info[kCGWindowOwnerName as String] as? String,
			let owningApplicationPID = info[kCGWindowOwnerPID as String] as? Int32,
			let applicationPath = NSRunningApplication(processIdentifier: owningApplicationPID)?.bundleURL?.path,
			let windowNumber = info[kCGWindowNumber as String] as? Int32,
			let windowLayer = info[kCGWindowLayer as String] as? Int,
			let windowTitle = info[kCGWindowName as String] as? String,
			let windowAlpha = info[kCGWindowAlpha as String] as? CGFloat,
			let windowMemoryUsage = info[kCGWindowMemoryUsage as String] as? Double,
			let windowSharingState = info[kCGWindowSharingState as String] as? Int32,
			let windowBackingType = info[kCGWindowStoreType as String] as? UInt32,
			let windowBounds = info[kCGWindowBounds as String] as? [String: Int32],
			let windowWidth = windowBounds["Width"],
			let windowHeight = windowBounds["Height"],
			let windowX = windowBounds["X"],
			let windowY = windowBounds["Y"]
		else {
			return nil
		}

		// TODO: Preserve the Emoji / Character Viewer
		// Exceptions: Character Viewer (Layer 20). Not caught.

		guard windowLayer == 0 else { return nil } // isWindow
		guard windowAlpha > 0 else  { return nil }
		guard !windowTitle.isEmpty || windowHeight > 70 else { return nil }

		if !Environment.preserveWindowsWithoutName {
			guard !windowTitle.isEmpty else { return nil }
		}

		if let blacklist: [String] = Environment.ignoredWindowNames {
			guard blacklist.firstIndex(of: windowTitle) == nil else {
				return nil
			}
		}

		let bounds = NSRect(
			origin: NSPoint(x: CGFloat(windowX), y: CGFloat(windowY)),
			size: NSSize(width: CGFloat(windowWidth), height: CGFloat(windowHeight))
		)

		self.owningApplicationName = String(owningApplicationName.unicodeScalars.prefix(while: { $0 != "." }))
		self.owningApplicationPID = owningApplicationPID
		self.applicationPath = applicationPath
		self.windowTitle = windowTitle.isEmpty ? owningApplicationName : windowTitle
		self.windowNumber = windowNumber
		self.windowAlpha = windowAlpha
		self.windowIsOnScreen = info[kCGWindowIsOnscreen as String] as? Bool ?? false
		self.windowLayer = windowLayer
		self.windowBounds = bounds
		self.windowBackingType = .init(rawValue: windowBackingType) ?? .backingStoreUnknown
		self.windowSharingState = .init(rawValue: windowSharingState) ?? .unknown
		self.windowMemoryUsage = windowMemoryUsage
		if let state: WindowMenuRepresentation = WindowNavigator.windowMenuStates[self.windowTitle] {
			self.isActiveWindow = state.isActive
			self.isMinimizedWindow = state.isMinimized
		} else {
			self.isActiveWindow = false
			self.isMinimizedWindow = false
		}

	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(windowBounds.size.width)
		hasher.combine(windowBounds.size.height)
		hasher.combine(windowBounds.origin.x)
		hasher.combine(windowBounds.origin.y)
		hasher.combine(self.windowTitle)
	}

	static func == (lhs: WindowWrapper, rhs: WindowWrapper) -> Bool {
		lhs.windowBounds == rhs.windowBounds
		&& lhs.windowTitle == rhs.windowTitle
	}

	// MARK: Window Wrapper Types
	// kCGWindowStoreType
	enum WindowBackingType: UInt32, CustomStringConvertible {
		case backingStoreRetained = 0
		case backingStoreNonretained = 1
		case backingStoreBuffered = 2
		case backingStoreUnknown = 404

		var description: String {
			switch self {
			case .backingStoreRetained: return "Backing Store Retained"
			case .backingStoreNonretained: return "Backing Store Nonretained"
			case .backingStoreBuffered: return "Backing Store Buffered"
			case .backingStoreUnknown: return "Backing Store Unexpected Unknown"
			}
		}
	}

	// kCGWindowSharingState
	enum WindowSharingState: Int32, CustomStringConvertible {
		case none = 1
		case readOnly = 2
		case readWrite = 3
		case unknown = 404

		var description: String {
			switch self {
			case .none: return "none"
			case .readOnly: return "read only"
			case .readWrite: return "read-write"
			case .unknown: return "sharing state unexpected unknown"
			}
		}
	}

	// MARK: Window Wrapper Utility
	// RIP CGWindowListCreateImage
	/// If we succeed in creating a composited image representation of the window, then it is an actual window visible somewhere on some workspace.
	var isValidWindow: Bool {
		if !Environment.includeMinimizedWindows {
			guard !isMinimizedWindow else { return false }
		}
		var title: String = windowTitle
		title.removeAll(where: { !$0.isLetter })
		let fuzzyComponents: [String] = windowTitle
			.components(separatedBy: .whitespaces)
			.filter({ $0.count > 1 && $0 != "Edited" })

		// Here Claude gets filtered out because it has no menu bar representation for its window
		if let candidates = WindowNavigator.windowCandidateNames,
		   (candidates.contains(windowTitle) || candidates.anySatisfy({ c in
			   fuzzyComponents.allSatisfy({ c.hasSubstring($0) })
		   }))
		{
			return true
		}
		return false
	}

	var debugDescription: String {
	"""
	Window {
		Application: \(owningApplicationName) (pid: \(owningApplicationPID))
		Window Name: 		\(windowTitle)
		 | Layer: 	 		\(windowLayer)
		 | Number:  		\(windowNumber)
		 | Alpha: 	 		\(windowAlpha)
		 | On Screen: 		\(windowIsOnScreen)
		 | Backing Type: 	\(windowBackingType.description)
		 | Sharing State: 	\(windowSharingState.description)
		 | Memory Usage: 	\(windowMemoryUsage)
		 | Window Bounds: {
		 width:  \(windowBounds.size.width)
		 height: \(windowBounds.size.height)
		 x: 		\(windowBounds.origin.x)
		 y: 		\(windowBounds.origin.y)
		}
	}
	"""
	}

	// MARK: Window Wrapper Alfred Item
	var alfredItem: Item {
		let text = Environment.isDebugPanelOpen
		? ["largetype":"\(windowTitle)\n\(owningApplicationName)\n\n\(debugDescription)"]
		: ["largetype":"\(windowTitle)\n\(owningApplicationName)"]

		let title: String = isActiveWindow ? "✓ \(windowTitle)" : isMinimizedWindow ? "♢ \(windowTitle)" :  windowTitle

		return .with {
			$0.title = title
			$0.subtitle = owningApplicationName
			$0.text = text
			$0.uid = windowTitle
			$0.autocomplete = "\(owningApplicationName) "
			$0.match = "\(windowTitle) \(owningApplicationName)"
			$0.icon = ["type": "fileicon", "path": applicationPath]
			$0.variables = [
				"app_pid":  "\(owningApplicationPID)",
				"app_name": "\(owningApplicationName)",
				"win_num":  "\(windowNumber)",
				"win_name": "\(windowTitle)",
				"directive": WindowNavigator.config.directive.reentryIdentifier
			]
		}
	}
}


// MARK: - Alfred Core

// MARK: - Alfred Response
struct Response: Codable {
	var items: [Item]
	var variables: [String:String]?
	var skipknowledge: Bool = true
	var rerun: Double?

	typealias CacheWrapper = WindowNavigator.Caching.CacheWrapper

	init(
		items: [Item],
		rerun: Double? = nil,
		variables: [String:String]? = ["trigger":"raise_window", "reentry_argument": WindowNavigator.config.query ?? ""]
	) {
		self.items = items
		self.rerun = rerun
		self.variables = variables
	}

	func encoded(
		fm: FileManager = .default, save saveCache: Bool,
		directive: Directive = WindowNavigator.config.directive,
		frontmost: String? = WindowNavigator.config.frontMostApplicationName
	) -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		if saveCache {
			let wrapper: CacheWrapper = .init(
				directive: directive,
				frontmostApplication: frontmost ?? "",
				timestamp: .now,
				response: self
			)

			if let cached: Data = fm.contents(atPath: Environment.cacheFile.path),
			   var cached: [CacheWrapper] = try? JSONDecoder().decode([CacheWrapper].self, from: cached)
			{
				if let replacementIndex = cached.firstIndex(where: { $0.directive == wrapper.directive }) {
					cached[replacementIndex] = wrapper
				} else {
					cached.append(wrapper)
				}
				let extendedCacheEncoded: Data = try! encoder.encode(cached)
				try? extendedCacheEncoded.write(to: Environment.cacheFile)
			} else {
				let cacheEncoded: Data = try! encoder.encode([wrapper])
				try? cacheEncoded.write(to: Environment.cacheFile)
			}

		}

		let encoded = try! encoder.encode(self)
		return encoded
	}
}

// MARK: - Alfred Item
struct Item: Codable, Hashable, Equatable, Inflatable {
	var title: String = ""
	var subtitle: String = ""
	var arg: [String]? = nil
	var uid: String? = nil
	var valid: Bool = true
	var match: String = ""
	var autocomplete: String? = nil
	var icon: [String: String]? = nil
	var text: [String:String]? = nil
	var variables: [String: String]? = nil

	static let noWindows: Item = .with {
		$0.valid = false
		$0.title = "No windows"
		$0.subtitle = WindowNavigator.config.directive.noWindowDescription
		$0.icon = ["path":"icons/info.png"]
	}

	static let noResults: Item = .with {
		$0.valid = false
		$0.title = "No results..."
		//$0.subtitle = "Ensure at least window exists with that name."
		$0.icon = ["path":"icons/info.png"]
	}
}


// MARK: - Environment Configuration
struct Environment {
	// Accessors
	static let env: [String:String] = ProcessInfo.processInfo.environment

	// Workflow State
	static let shouldRaiseWindow: Bool = env["trigger"] == "raise_window" && env["app_pid"] != nil && env["win_num"] != nil && env["win_name"] != nil
	static let shouldCloseWindow: Bool = env["trigger"] == "close_window" && env["app_pid"] != nil && env["win_num"] != nil && env["win_name"] != nil

	// Window Properties
	static let applicationPID: Int32 = Int32(env["app_pid"]!)!
	static let windowNumber: Int32 = Int32(env["win_num"]!)!
	static let windowName: String = env["win_name"]!
	static let owningApplicationName: String? = env["app_name"]

	// Configuration Settings
	static let includeFrontmostWindow: Bool = env["include_top_win"] == "1"
	static let preserveWindowsWithoutName: Bool = env["preserve_unnamed_windows"] == "1"
	static let includeMinimizedWindows: Bool = env["show_minimized_windows"] == "1"
	static let ignoredWindowNames: [String]? = env["ignored_window_names"]?.split(separator: ",").map(\.trimmed)
	static let presentsSpecialCase: Bool = env["special_case"] == "yes"
	static let specialCaseBundleID: String? = env["owner"] // not strictly necessary


	// Debugging & Diagnostics
	static let isDebugPanelOpen: Bool = env["alfred_debug"] == "1"

	// Caching & Persistence
	static let cacheLifetime: TimeInterval = TimeInterval(env["cache_lifetime"] ?? "2400")! // 1200 - 20 mins
	static let cacheFolder: URL = URL(file: env["alfred_workflow_cache"]!)
	static let cacheFile: URL = cacheFolder.appendingPathComponent("windows.json")
	static let cacheFeedbackGiven: Bool = env["cache_feedback_given"] == "true"
	static let dataFolder: URL = URL(file: env["alfred_workflow_data"]!)
	static let runtimeFraudsFile: URL = dataFolder.appending(component: "runtime_frauds.txt")
	static let queryMemoryFile: URL = cacheFolder.appending(component: "query_memory.txt")
	static let forceRefreshFile: URL = cacheFolder.appending(component: "force_refresh")

	// Logging
	static private let stdErr: FileHandle = .standardError
	static func log(_ message: String) {
		if isDebugPanelOpen {
			try? stdErr.write(contentsOf: Data("\(message)\n".utf8))
		}
	}
}


// MARK: - Extensions

// MARK: - AXUIElement Extensions
extension AXUIElement {

	var name: String? { getAttribute(named: kAXTitleAttribute) }
	var children: [AXUIElement]? { getAttribute(named: kAXChildrenAttribute) }
	var menunBar: AXUIElement? { getAttribute(named: kAXMenuBarAttribute) }

	var isActiveWindowRepresentation: Bool {
		if let presentCheckmark: String = getAttribute(named: kAXMenuItemMarkCharAttribute), presentCheckmark == "✓" {
			return true
		}
		return false
	}

	var isMinimizedWindowRepresentation: Bool {
		if let markChar: String = getAttribute(named: kAXMenuItemMarkCharAttribute), markChar == "◆" {
			return true
		}
		return false
	}

	func getAttribute<T>(named axAttributeName: String, log: Bool = false) -> T? {
		var value: CFTypeRef?
		let state: AXError = AXUIElementCopyAttributeValue(self, axAttributeName as CFString, &value)
		guard state == .success else {
			if log { Environment.log("[Info] Failed to get attribute with name '\(axAttributeName)' from AXUIElement (\(state.debugDescription))") }
			return nil
		}
		return value as? T
	}

	@discardableResult
	func press() -> Bool {
		let state: AXError = AXUIElementPerformAction(self, kAXPressAction as CFString)
		guard state == .success else {
			Environment.log("[Warning] Failed to click AXUIElement with name '\(self.name ?? "N/A")' (\(state.debugDescription))")
			return false
		}
		return true
	}

	/// If the targeted window is within the active desktop space, we can neglect any concerns about restoring the previous user window / desktop state.
	///
	/// - Note: This function can only succeed if the calling `AXUIElement` is a top-level accessibility object for an application.
	func windowWithinCurrentDesktopSpace(windowNumber: Int32) -> AXUIElement? {
		guard let axWindows: [AXUIElement] = self.getAttribute(named: kAXWindowsAttribute) else {
			return nil
		}
		var axWindowNumber: CGWindowID = 0
		for axWindow in axWindows {
			_AXUIElementGetWindow(axWindow, &axWindowNumber)
			if axWindowNumber == windowNumber {
				return axWindow
			}
		}
		return nil
	}

	/// Get the menu bar item matching the givien predicate.
	///
	/// - Note: This function can only succeed if the calling `AXUIElement` is an accessibility object representing the menu bar of an application.
	func firstMenuBarItem(where predicate: (AXUIElement) throws -> Bool) rethrows -> AXUIElement? {
		if let children: [AXUIElement] = getAttribute(named: kAXChildrenAttribute) {
			// Reverse the array to crawl the list starting with Help > Window ... then each sub bar from the bottom
			for child: AXUIElement in children.reversed() {
				if try predicate(child) {
					return child
				}
				if let matched: AXUIElement = try? child.firstMenuBarItem(where: predicate) {
					return matched
				}
			}
		}
		return nil
	}

	func firstMenuBarItem(named targetName: String) -> AXUIElement? {
		let fuzzyComponents: [String] = targetName.components(separatedBy: .whitespaces).filter({ $0.count > 1 && $0 != "Edited" })
		return firstMenuBarItem(where: { child in
			if let name: String = child.getAttribute(named: kAXTitleAttribute) {
				if (name == targetName || fuzzyComponents.allSatisfy({ name.contains($0) })) {
					// Skip e.g. 'Dictionary Help'
					if name != "\(targetName) Help" {
						return true
					}
				}
			}
			return false
		})
	}
}

// MARK: AXError Extensions
extension AXError: @retroactive CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .notImplemented: return "This error indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API)."
		case .cannotComplete: return "A fundamental error has occurred, such as a failure to allocate memory during processing."
		case .invalidUIElementObserver: return "The observer for the accessibility object received in this event is invalid."
		case .illegalArgument: return "The value received in this event is an invalid value for this attribute."
		case .apiDisabled: return "API Disabled. Assistive applications are not enabled in System Preferences."
		case .notificationAlreadyRegistered: return "This notification has already been registered for."
		case .notificationUnsupported: return "The notification is not supported by the AXUIElementRef."
		case .parameterizedAttributeUnsupported: return "The parameterized attribute is not supported."
		case .notificationNotRegistered: return "Indicates that a notification is not registered yet."
		case .invalidUIElement: return "The accessibility object received in this event is invalid."
		case .failure: return "A system error occurred, such as the failure to allocate an object."
		case .attributeUnsupported: return "The referenced attribute is not supported."
		case .noValue: return "The requested value or AXUIElementRef does not exist."
		case .actionUnsupported: return "The referenced action is not supported."
		case .notEnoughPrecision: return "Not enough precision."
		case .success: return "No error occurred."
		@unknown default:
			return "An unknown error has occurred (\(self.rawValue))."
		}
	}
}

// MARK: String Extensions
extension String {
	func droppingSuffix(_ suffix: String) -> String {
		if hasSuffix(suffix) {
			return self.dropLast(suffix.count).trimmed
		} else {
			return self
		}
	}

	func hasSubstring<T: StringProtocol>(_ other: T, options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]) -> Bool {
		range(of: other, options: options) != nil
	}
}

extension StringProtocol {
	var trimmed: String {
		self.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}

// MARK: Collection Extensions
extension Collection {
	func anySatisfy(_ p: (Element) -> Bool) -> Bool {
		return !self.allSatisfy { !p($0) }
	}
}

extension Array where Element: Hashable {
	func deduplicated() -> [Element] {
		var seen: Set<Element> = []
		return filter { seen.insert($0).inserted }
	}

	subscript (safe index: Int) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}

extension Set where Element == String {
	static func observedFrauds(fm: FileManager = .default) -> Set<String> {
		guard fm.fileExists(atPath: Environment.runtimeFraudsFile.path) else { return [] }
		do {
			return try Environment.runtimeFraudsFile.contents()
		} catch {
			Environment.log("Error reading previous frauds (false positives): \(error)")
			return []
		}
	}
}

// MARK: URL Extensions
extension URL {
	init(file: String) {
		if #available(macOS 14, *) {
			self = URL(filePath: file)
		} else {
			self = URL(fileURLWithPath: file)
		}
	}

	func contents() throws -> Set<String> {
		var data = try Data(contentsOf: self)
		data += Data("".utf8) // NSData Bridging
		var elements: Set<String> = []
		data.withUnsafeBytes { rawPointer in
			for line in rawPointer.split(separator: UInt8(ascii: "\n")) {
				elements.insert(String(decoding: UnsafeRawBufferPointer(rebasing: line), as: UTF8.self))
			}
		}
		return elements
	}
}




// MARK: - Main Entry

if Environment.shouldCloseWindow { await WindowNavigator.AX.close() }
if Environment.shouldRaiseWindow { await WindowNavigator.AX.raise() }
WindowNavigator.permissions()
await WindowNavigator.run()

try? await Task.sleep(for: .seconds(10)) // RunLoop replacement
