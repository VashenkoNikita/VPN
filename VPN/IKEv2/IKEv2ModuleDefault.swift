//
//  IKEv2ModuleDefault.swift
//  VPN
//
//  Created by NikitaV on 21.06.2022.
//

import Foundation
import NetworkExtension

class VPNIKEv2Setup {
    
    static let shared = VPNIKEv2Setup()

    let vpnManager = NEVPNManager.shared()
    
    func initVPNTunnelProviderManager() {

        print("CALL LOAD TO PREFERENCES...")
        self.vpnManager.loadFromPreferences { [self] (error) -> Void in
            
            if((error) != nil) {

                print("VPN Preferences error: 1 - \(String(describing: error))")
            } else {

                let IKEv2Protocol = NEVPNProtocolIKEv2()
                
                IKEv2Protocol.authenticationMethod = .certificate
                IKEv2Protocol.serverAddress = VPNServerSettings.shared.vpnServerAddress
                IKEv2Protocol.remoteIdentifier = VPNServerSettings.shared.vpnRemoteIdentifier
                IKEv2Protocol.localIdentifier = VPNServerSettings.shared.vpnLocalIdentifier

                IKEv2Protocol.useExtendedAuthentication = false
                IKEv2Protocol.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256GCM
                IKEv2Protocol.ikeSecurityAssociationParameters.diffieHellmanGroup = .group20
                IKEv2Protocol.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA512
                IKEv2Protocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440

                IKEv2Protocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256GCM
                IKEv2Protocol.childSecurityAssociationParameters.diffieHellmanGroup = .group20
                IKEv2Protocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA512
                IKEv2Protocol.childSecurityAssociationParameters.lifetimeMinutes = 1440
                
                IKEv2Protocol.deadPeerDetectionRate = .medium
                IKEv2Protocol.disableRedirect = true
                IKEv2Protocol.disableMOBIKE = false
                IKEv2Protocol.enableRevocationCheck = false
                IKEv2Protocol.enablePFS = true
                IKEv2Protocol.useConfigurationAttributeInternalIPSubnet = false

                IKEv2Protocol.serverCertificateIssuerCommonName = VPNServerSettings.shared.vpnServerCertificateIssuerCommonName
                IKEv2Protocol.disconnectOnSleep = false
                IKEv2Protocol.certificateType = .ECDSA384
                IKEv2Protocol.identityDataPassword = VPNServerSettings.shared.p12Password
                IKEv2Protocol.identityData = self.dataFromFile()

                self.vpnManager.protocolConfiguration = IKEv2Protocol
                self.vpnManager.localizedDescription = "Venom VPN"
                self.vpnManager.isEnabled = true
                self.vpnManager.isOnDemandEnabled = false

                //Set rules
                var rules = [NEOnDemandRule]()
                let rule = NEOnDemandRuleConnect()
                rule.interfaceTypeMatch = .any
                rules.append(rule)
//                self.vpnManager.onDemandRules = rules
                print("SAVE TO PREFERENCES...")
                //SAVE TO PREFERENCES...
                self.vpnManager.saveToPreferences(completionHandler: { (error) -> Void in
                    if((error) != nil) {

                        print("VPN Preferences error: 2 - \(String(describing: error))")
                    } else {

                        print("CALL LOAD TO PREFERENCES AGAIN...")
                        //CALL LOAD TO PREFERENCES AGAIN...
                        self.vpnManager.loadFromPreferences(completionHandler: { (error) in
                            if ((error) != nil) {
                                print("VPN Preferences error: 2 - \(String(describing: error))")
                            } else {
                                var startError: NSError?

                                do {
                                    //START THE CONNECTION...
                                    try self.vpnManager.connection.startVPNTunnel()
                                } catch let error as NSError {

                                    startError = error
                                    print(startError.debugDescription)
                                } catch {

                                    print("Fatal Error")
                                    fatalError()
                                }
                                if ((startError) != nil) {
                                    print("VPN Preferences error: 3 - \(String(describing: error))")

                                    //Show alert here
                                    print("title: Oops.., message: Something went wrong while connecting to the VPN. Please try again.")

                                    print(startError.debugDescription)
                                } else {

                                    print("Starting VPN...")
                                }
                            }
                        })
                    }
                })
            }
        }

    }

    //MARK:- Connect VPN
    static func connectVPN() {
        VPNIKEv2Setup().initVPNTunnelProviderManager()
        
    }

    //MARK:- Disconnect VPN
    static func disconnectVPN() {
        VPNIKEv2Setup().vpnManager.connection.stopVPNTunnel()
    }
    
    //MARK:- Disconnect VPN
    static func testConnect() {
        do {
            try VPNIKEv2Setup().vpnManager.connection.startVPNTunnel()
        } catch let error {
            print(error)
        }
    }

    //MARK:- check connection staatus
    static func checkStatus() {

        let status = VPNIKEv2Setup().vpnManager.connection.status
        print("VPN connection status = \(status.rawValue)")

        switch status {
        case NEVPNStatus.connected:

            print("Connected")

        case NEVPNStatus.invalid, NEVPNStatus.disconnected :

            print("Disconnected")

        case NEVPNStatus.connecting , NEVPNStatus.reasserting:

            print("Connecting")

        case NEVPNStatus.disconnecting:

            print("Disconnecting")

        default:
            print("Unknown VPN connection status")
        }
    }
    
    func dataFromFile() -> Data? {
        let rootCertPath = Bundle.main.url(forResource: "phone", withExtension: "p12")
        print(rootCertPath?.absoluteURL as Any)
        guard let rootCertPath = rootCertPath else { return Data()}
        return try? Data(contentsOf: rootCertPath.absoluteURL)
    }
    
}

protocol VPNServerSettingsProtocol: AnyObject {
    var p12Password: String { get set }
    var vpnServerAddress: String { get set }
    var vpnRemoteIdentifier: String { get set }
    var vpnLocalIdentifier: String { get set }
    var vpnServerCertificateIssuerCommonName: String { get set }
}

class VPNServerSettings: NSObject, VPNServerSettingsProtocol {
    static let shared = VPNServerSettings()
    
    var p12Password = "*****" // password from file certificate "****.p12"
    var vpnServerAddress = "******"
    var vpnRemoteIdentifier = "*******" // In my case same like vpn server address
    var vpnLocalIdentifier = "phone@caf1e9*******.algo"
    var vpnServerCertificateIssuerCommonName = "*******" // In my case same like vpn server address
}


