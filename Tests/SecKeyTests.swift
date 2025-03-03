//
//  SecKeyTests.swift
//  Shield
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import Shield
import XCTest

class SecKeyTests: XCTestCase {

  func testRSA() throws {
    let keyPair = try SecKeyPair.Builder(type: .rsa, keySize: 2048).generate(label: "Test")
    defer { try? keyPair.delete() }

    print("Checking: RSA Encrypt/Decrypt")
    try testEncryptDecrypt(keyPair)
    testFailedEncryptError(keyPair)
    testFailedDecryptError(keyPair)

    print("Checking: RSA Sign/Verify")
    try testSignVerifySHA1(keyPair)
    try testSignVerifySHA224(keyPair)
    try testSignVerifySHA256(keyPair)
    try testSignVerifySHA384(keyPair)
    try testSignVerifySHA512(keyPair)
    try testSignVerifyFailed(keyPair)

    print("Checking: RSA Encode/Decode")
    try testEncodeDecode(keyPair)

  }

  func testEC() throws {
    let keyPair = try SecKeyPair.Builder(type: .ec, keySize: 256).generate(label: "Test")

    print("Checking: EC Encrypt/Decrypt")
    testFailedEncryptError(keyPair)
    testFailedDecryptError(keyPair)

    print("Checking: EC Sign/Verify")
    try testSignVerifySHA1(keyPair)
    try testSignVerifySHA224(keyPair)
    try testSignVerifySHA256(keyPair)
    try testSignVerifySHA384(keyPair)
    try testSignVerifySHA512(keyPair)
    try testSignVerifyFailed(keyPair)

    print("Checking: EC Encode/Decode")
    try testEncodeDecode(keyPair)

  }

  func testECGeneration() throws {
    try [192, 256, 384, 521].forEach { keySize in

      let keyPair = try SecKeyPair.Builder(type: .ec, keySize: keySize).generate(label: "Test")
      defer { try? keyPair.delete() }

      _ = try AlgorithmIdentifier(publicKey: keyPair.publicKey)
    }
  }

  func testSignVerifySHA1(_ keyPair: SecKeyPair) throws {

    let data = try Random.generate(count: 217)

    let signature = try keyPair.privateKey.sign(data: data, digestAlgorithm: .sha1)

    XCTAssertTrue(try keyPair.publicKey.verify(
      data: data,
      againstSignature: signature,
      digestAlgorithm: .sha1
    ))
  }

  func testSignVerifySHA224(_ keyPair: SecKeyPair) throws {

    let data = try Random.generate(count: 217)

    let signature = try keyPair.privateKey.sign(data: data, digestAlgorithm: .sha224)

    XCTAssertTrue(try keyPair.publicKey.verify(
      data: data,
      againstSignature: signature,
      digestAlgorithm: .sha224
    ))
  }

  func testSignVerifySHA256(_ keyPair: SecKeyPair) throws {

    let data = try Random.generate(count: 217)

    let signature = try keyPair.privateKey.sign(data: data, digestAlgorithm: .sha256)

    XCTAssertTrue(try keyPair.publicKey.verify(
      data: data,
      againstSignature: signature,
      digestAlgorithm: .sha256
    ))
  }

  func testSignVerifySHA384(_ keyPair: SecKeyPair) throws {

    let data = try Random.generate(count: 217)

    let signature = try keyPair.privateKey.sign(data: data, digestAlgorithm: .sha384)

    XCTAssertTrue(try keyPair.publicKey.verify(
      data: data,
      againstSignature: signature,
      digestAlgorithm: .sha384
    ))
  }

  func testSignVerifySHA512(_ keyPair: SecKeyPair) throws {

    let data = try Random.generate(count: 217)

    let signature = try keyPair.privateKey.sign(data: data, digestAlgorithm: .sha512)

    XCTAssertTrue(try keyPair.publicKey.verify(
      data: data,
      againstSignature: signature,
      digestAlgorithm: .sha512
    ))
  }

  func testSignVerifyFailed(_ keyPair: SecKeyPair) throws {

    let invalidSignature = try keyPair.privateKey.sign(data: try Random.generate(count: 217), digestAlgorithm: .sha1)

    XCTAssertFalse(try keyPair.publicKey.verify(
      data: try Random.generate(count: 217),
      againstSignature: invalidSignature,
      digestAlgorithm: .sha1
    ))
  }

  func testEncodeDecode(_ keyPair: SecKeyPair) throws {

    let encodedPublicKey = try keyPair.publicKey.encode()
    let decodedPublicKey = try SecKey.decode(
      data: encodedPublicKey,
      type: keyPair.publicKey.type() as CFString,
      class: kSecAttrKeyClassPublic
    )

    let encodedPrivateKey = try keyPair.privateKey.encode()
    let decodedPrivateKey = try SecKey.decode(
      data: encodedPrivateKey,
      type: keyPair.publicKey.type() as CFString,
      class: kSecAttrKeyClassPrivate
    )

    guard try keyPair.publicKey.keyType() != .ec else {
      return
    }

    let plainText = try Random.generate(count: 143)

    let cipherText1 = try keyPair.publicKey.encrypt(plainText: plainText, padding: .oaep)

    let cipherText2 = try decodedPublicKey.encrypt(plainText: plainText, padding: .oaep)

    XCTAssertEqual(plainText, try decodedPrivateKey.decrypt(cipherText: cipherText1, padding: .oaep))
    XCTAssertEqual(plainText, try decodedPrivateKey.decrypt(cipherText: cipherText2, padding: .oaep))
  }

  func testEncryptDecrypt(_ keyPair: SecKeyPair) throws {

    let plainText = try Random.generate(count: 171)

    let cipherText = try keyPair.publicKey.encrypt(plainText: plainText, padding: .oaep)

    let plainText2 = try keyPair.privateKey.decrypt(cipherText: cipherText, padding: .oaep)

    XCTAssertEqual(plainText, plainText2)
  }

  func testFailedEncryptError(_ keyPair: SecKeyPair) {

    do {
      _ = try keyPair.publicKey.encrypt(plainText: try Random.generate(count: 312), padding: .oaep)
      XCTFail("Encrypt should have thrown an error")
    }
    catch _ {}
  }

  func testFailedDecryptError(_ keyPair: SecKeyPair) {

    do {
      _ = try keyPair.privateKey.decrypt(cipherText: try Random.generate(count: 312), padding: .oaep)
      XCTFail("Decrypt should have thrown an error")
    }
    catch _ {}
  }

}
