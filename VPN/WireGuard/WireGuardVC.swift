//
//  WireGuardVC.swift
//  VPN
//
//  Created by NikitaV on 21.06.2022.
//

import UIKit
import TunnelKitManager
import TunnelKitWireGuard

private let appGroup = "group.com.algoritmico.TunnelKit.Demo"

private let tunnelIdentifier = "com.algoritmico.ios.TunnelKit.Demo.WireGuard.Tunnel"

class WireGuardViewController: UIViewController {
    @IBOutlet var textClientPrivateKey: UITextField!
    
    @IBOutlet var textAddress: UITextField!
    
    @IBOutlet var textServerPublicKey: UITextField!
    
    @IBOutlet var textServerAddress: UITextField!
    
    @IBOutlet var textServerPort: UITextField!
    
    @IBOutlet var buttonConnection: UIButton!
    
    private let vpn = NetworkExtensionVPN()
    
    private var vpnStatus: VPNStatus = .disconnected

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textClientPrivateKey.placeholder = "client private key"
        textAddress.placeholder = "client address"
        textServerPublicKey.placeholder = "server public key"
        textServerAddress.placeholder = "server address"
        textServerPort.placeholder = "server port"

        textAddress.text = "192.168.30.2/32"

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNStatusDidChange(notification:)),
            name: VPNNotification.didChangeStatus,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNDidFail(notification:)),
            name: VPNNotification.didFail,
            object: nil
        )

        Task {
            await vpn.prepare()
        }
    }

    @IBAction func connectionClicked(_ sender: Any) {
        switch vpnStatus {
        case .disconnected:
            connect()
            
        case .connected, .connecting, .disconnecting:
            disconnect()
        }
    }

    func connect() {
        guard let clientPrivateKey = textClientPrivateKey.text else { return }
        guard let clientAddress = textAddress.text else { return }
        guard let serverPublicKey = textServerPublicKey.text else { return }
        guard let serverAddress = textServerAddress.text else { return }
        guard let serverPort = textServerPort.text else { return }

        guard let cfg = WireGuard.DemoConfiguration.make(
            "TunnelKit.WireGuard",
            appGroup: appGroup,
            clientPrivateKey: clientPrivateKey,
            clientAddress: clientAddress,
            serverPublicKey: serverPublicKey,
            serverAddress: serverAddress,
            serverPort: serverPort
        ) else {
            print("Configuration incomplete")
            return
        }

        Task {
            try await vpn.reconnect(
                tunnelIdentifier,
                configuration: cfg,
                extra: nil,
                after: .seconds(2)
            )
        }
    }
    
    func disconnect() {
        Task {
            await vpn.disconnect()
        }
    }

    func updateButton() {
        switch vpnStatus {
        case .connected, .connecting:
            buttonConnection.setTitle("Disconnect", for: .normal)
            
        case .disconnected:
            buttonConnection.setTitle("Connect", for: .normal)
            
        case .disconnecting:
            buttonConnection.setTitle("Disconnecting", for: .normal)
        }
    }
    
    @objc private func VPNStatusDidChange(notification: Notification) {
        vpnStatus = notification.vpnStatus
        print("VPNStatusDidChange: \(notification.vpnStatus)")
        updateButton()
    }

    @objc private func VPNDidFail(notification: Notification) {
        print("VPNStatusDidFail: \(notification.vpnError.localizedDescription)")
    }
}

