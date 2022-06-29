//
//  Config.swift
//  VPN
//
//  Created by NikitaV on 27.06.2022.
//

import Foundation
import TunnelKitCore
import TunnelKitWireGuard

extension WireGuard {
    struct DemoConfiguration {
        static func make(
            _ title: String,
            appGroup: String,
            clientPrivateKey: String,
            clientAddress: String,
            serverPublicKey: String,
            serverAddress: String,
            serverPort: String
        ) -> WireGuard.ProviderConfiguration? {
            var builder = try! WireGuard.ConfigurationBuilder(clientPrivateKey)
            builder.addresses = [clientAddress]
            builder.dnsServers = ["1.1.1.1", "1.0.0.1"]
            try! builder.addPeer(serverPublicKey, endpoint: "\(serverAddress):\(serverPort)")
            builder.addDefaultGatewayIPv4(toPeer: 0)
            let cfg = builder.build()

            return WireGuard.ProviderConfiguration(title, appGroup: appGroup, configuration: cfg)
        }
    }
}
