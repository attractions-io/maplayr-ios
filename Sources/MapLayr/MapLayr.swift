//
//  MapLayr.swift
//  MapLayr
//
//  Created by Robert Pugh on 2023-09-27.
//

import Foundation
import ZIPFoundation

@_exported import MapLayrInternal
@_exported import MapGeometry

let zipExtractor = { @Sendable (sourceZipFile: URL, targetDirectory: URL) in
	try FileManager.default.unzipItem(at: sourceZipFile, to: targetDirectory)
}

extension Map {
	/// Returns a managed map with the given map ID.
	///
	/// Use this method if your map is managed by AppLayr and a copy is included in the application bundle. Map views using maps returned by this method will automatically update if new versions of the map become available.
	///
	/// If a map with the same ID still exists which was previously returned from this method, that same map instance will be returned.
	///
	/// - Parameters:
	///   - id: The ID of the map to load.
	///
	/// - Returns: The newly loaded map (or an existing map if a managed map with the same ID was already loaded).
	public static func managed(id: String) throws -> Map {
		try self._managed(id: id, extractor: zipExtractor)
	}
	
	/// Returns a managed map with the given map ID.
	///
	/// Use this method if your map is managed by AppLayr but a copy is *not* guaranteed to be included in the application bundle. If a local copy of the map isn't available, a full copy of the map will be downloaded first. Map views using maps returned by this method will automatically update if new versions of the map become available.
	///
	/// If a map with the same ID still exists which was previously returned from this method, that same map instance will be returned.
	///
	/// - Parameters:
	///   - id: The ID of the map to load.
	///
	/// - Returns: The newly loaded map (or an existing map if a managed map with the same ID was already loaded).
	public static func managed(id: String) async throws -> Map {
		try await self._managed(id: id, extractor: zipExtractor)
	}
}
