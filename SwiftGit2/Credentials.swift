//
//  Credentials.swift
//  SwiftGit2
//
//  Created by Tom Booth on 29/02/2016.
//  Copyright © 2016 GitHub, Inc. All rights reserved.
//

import Foundation
import Result

/// A Swift mapping of git_credtype_t
public struct CredentialType : OptionSetType {
	public let rawValue: UInt32
	public init(rawValue: UInt32) { self.rawValue = rawValue }
	public init(_ credtype: git_credtype_t) {
		self.rawValue = UInt32(credtype.rawValue)
	}

	public static let UserPassPlainText = CredentialType(GIT_CREDTYPE_USERPASS_PLAINTEXT)
	public static let SSHKey = CredentialType(GIT_CREDTYPE_SSH_KEY)
	public static let SSHCustom = CredentialType(GIT_CREDTYPE_SSH_CUSTOM)
	public static let Default = CredentialType(GIT_CREDTYPE_DEFAULT)
	public static let SSHInteractive = CredentialType(GIT_CREDTYPE_SSH_INTERACTIVE)
	public static let Username = CredentialType(GIT_CREDTYPE_USERNAME)
	public static let SSHMemory = CredentialType(GIT_CREDTYPE_SSH_MEMORY)
}

/// A function that takes a list of allowed credential types, the URL of the repository
/// to be accessed and the username the transport is using to connect. Using these arguments
/// it either rejects by returning nil or returns an object that implements the Credential
/// protocol.
///
/// ```swift
/// { (allowedTypes: CredentialType, URL: String?, userName: String?) -> Credential? in
///    // work out if we can provide a credential
///    return SSHMemoryCredential(...)
/// }
/// ```
public typealias CredentialsProvider = (CredentialType, String?, String?) -> Credential?

/// A reference to a git_cred object used when a transport is requesting a set of credentials
public typealias CredentialReference = UnsafeMutablePointer<UnsafeMutablePointer<git_cred>>

/// A protocol for objects that can pass through a credential to a transport
public protocol Credential {
	func realise(reference: CredentialReference) -> Result<Int32, NSError>
}

/// An implmentation of a SSH in-memory stored credential
public struct SSHMemoryCredential : Credential {

	let username: String, publicKey: String, privateKey: String, passphrase: String

	/// Initialise an in-memory SSH key pair
	///
	/// username - The username the key pair corresponds to
	/// publicKey - The public key data as a string
	/// privateKey - The private key data as a string
	/// passphrase - The passphrase used to unlock the private key, blank string if none.
	public init(username: String, publicKey: String, privateKey: String, passphrase: String) {
		self.username = username
		self.publicKey = publicKey
		self.privateKey = privateKey
		self.passphrase = passphrase
	}

	public func realise(reference: CredentialReference) -> Result<Int32, NSError> {
		let result = git_cred_ssh_key_memory_new(reference, username, publicKey, privateKey, passphrase)

		if result != GIT_OK.rawValue {
			return Result.Failure(libGit2Error(result, libGit2PointOfFailure: "git_cred_ssh_key_memory_new"))
		}

		return Result.Success(result)
	}

}
