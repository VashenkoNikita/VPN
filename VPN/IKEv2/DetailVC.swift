//
//  DetailVC.swift
//  VPN
//
//  Created by NikitaV on 21.06.2022.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var p12PasswordTF: UITextField!
    @IBOutlet weak var vpnServerAddressTF: UITextField!
    @IBOutlet weak var vpnRemoteIdentifierTF: UITextField!
    @IBOutlet weak var vpnLocalIdentifierTF: UITextField!
    @IBOutlet weak var vpnServerCertificateIssuerCommonNameTF: UITextField!
    @IBOutlet weak var buttonConnected: UIButton!
    
    var flagVPNConneting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func buttonConnect(_ sender: Any) {
        guard let p12PasswordTF = p12PasswordTF.text,
              let vpnServerAddressTF = vpnServerAddressTF.text,
              let vpnRemoteIdentifierTF = vpnRemoteIdentifierTF.text,
              let vpnLocalIdentifierTF = vpnLocalIdentifierTF.text,
              let vpnServerCertificateIssuerCommonNameTF = vpnServerCertificateIssuerCommonNameTF.text
        else { return }
                        
        VPNServerSettings.shared.p12Password = p12PasswordTF
        VPNServerSettings.shared.vpnLocalIdentifier = vpnServerAddressTF
        VPNServerSettings.shared.vpnRemoteIdentifier = vpnRemoteIdentifierTF
        VPNServerSettings.shared.vpnServerAddress = vpnLocalIdentifierTF
        VPNServerSettings.shared.vpnServerCertificateIssuerCommonName = vpnServerCertificateIssuerCommonNameTF
        
        VPNIKEv2Setup.shared.initVPNTunnelProviderManager()
        
        if flagVPNConneting == true {
            VPNIKEv2Setup.disconnectVPN()
            buttonConnected.setTitle("VPN Connected", for: .normal)
            VPNIKEv2Setup.checkStatus()
            flagVPNConneting = false
        } else {
            VPNIKEv2Setup.connectVPN()
            buttonConnected.setTitle("VPN Disable", for: .normal)
            VPNIKEv2Setup.checkStatus()
            flagVPNConneting = true
        }
    }
    
    
    private func createAlert(text: String) {
        let ac =  UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        ac.addAction(ok)
        present(ac, animated: true)
    }
}

