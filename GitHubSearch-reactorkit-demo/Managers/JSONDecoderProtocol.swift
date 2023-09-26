//
//  JSONDecoderProtocol.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/26/23.
//

import Foundation

protocol JSONDecoderProtocol {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable

    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func decode<T>(_ type: T.Type, from data: Data, configuration: T.DecodingConfiguration) throws -> T where T : DecodableWithConfiguration

    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func decode<T, C>(_ type: T.Type, from data: Data, configuration: C.Type) throws -> T where T : DecodableWithConfiguration, C : DecodingConfigurationProviding, T.DecodingConfiguration == C.DecodingConfiguration
}

extension JSONDecoder: JSONDecoderProtocol {}
