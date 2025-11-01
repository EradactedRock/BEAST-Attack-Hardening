# BEAST-Attack-Hardening
Windows SCHANNEL Hardening Project

This project remediates the BEAST attack (Browser Exploit Against SSL/TLS) and strengthens the overall security posture of Windows servers and clients by enforcing modern TLS protocols, disabling legacy ciphers and hashes, and defining a secure cipher suite order. It leverages IIS Crypto, custom XML templates, and PDQ Connect to automate deployment across the environment.

---

## Background

The BEAST attack is a vulnerability in SSL/TLS (specifically affecting TLS 1.0 and SSL 3.0) that allows attackers to exploit block cipher modes (like CBC) and decrypt sensitive data. This project was started to disable vulnerable protocols and ciphers and ensure that only secure, modern algorithms are used for TLS communication.

---

## Files found in GitHub

- `Apply_IISCrypto_Strict.bat`  
  This is the script used to make the registry changes on the end user machine.

- `IISCrypto_Template_XML.txt`  
  This XML file was spawned out of the ICTPL file, which is the template used by IIS Crypto to make the registry changes. The purpose of extracting the XML file was so that ChatGPT can have a reference file of the exact configuration needed to be made.

- `PDQ_IISHardening_Script.ps1`  
  This script was used to set up a package deployment in PDQ Connect. After creating the package deployment, we are able to remotely deploy the registry changes to end user machines.

- `SCHANNEL Configuration.png`  
  A picture of the SCHANNEL configuration page in IIS Crypto GUI. The GUI was used to build the Protocols, Ciphers, Hashes, and Key Exchanges needed to be enabled/disabled. These changes also updated the CIPHER suites to allow for the safest communication exchange order.

---

## Key Steps & Components

### 1 Initial Hardening with IIS Crypto
- Used IIS Crypto to generate an initial secure configuration.
- Disabled weak protocols (SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1).
- Enabled only TLS 1.2 and TLS 1.3 for both client and server.
- Selected only secure ciphers: AES 128/128, AES 256/256.
- Enabled strong hashes: SHA256, SHA384, and SHA512.
- Configured key exchange algorithms: Diffie-Hellman, PKCS, and ECDH.

### 2 Created a .ictpl Template
- Exported the secure configuration from IIS Crypto into an .ictpl file.
- The XML format captures all protocol, cipher, hash, and key exchange settings in a portable, shareable format.

### 3 Converted .ictpl to .reg Script
- Parsed the .ictpl XML and manually translated its settings into Windows registry keys:  
  - Protocols: Enabled/disabled in SCHANNEL.  
  - Ciphers: Enabled/disabled in SCHANNEL.  
  - Hashes: Enabled/disabled in SCHANNEL.  
  - Key Exchange: Enabled/disabled in SCHANNEL.  
  - Cipher Suite Order: Defined using the Functions key.

### 4 Automated Deployment with PDQ Connect
- Created a PDQ Connect package to deploy the .reg file to all affected Windows servers and clients.
- Configured the package to:  
  - Import the registry settings silently.  
  - Reboot the machine to apply changes.

---

## Latest Registry Configuration

The final .reg script includes:

- Enabled TLS 1.2 and TLS 1.3 (Client & Server)  
- Disabled SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1, and PCT 1.0  
- Enabled only AES 128/128 and AES 256/256 ciphers  
- Disabled all other weak ciphers  
- Enabled SHA256, SHA384, SHA512 hashes  
- Disabled MD5 and SHA1 hashes  
- Enabled key exchange algorithms: Diffie-Hellman, PKCS, and ECDH  
- Set minimum DHE key length to 2048 bits  
- Disabled FIPS Algorithm Policy  
- Included full cipher suite ordering to maintain compatibility while enforcing security  

---

## Testing

During initial testing, applying the registry changes caused applications like Microsoft Teams, Outlook, and Remote Connection Software to fail connecting to servers. These are priority applications that must function.

Verify TLS functionality using:  
- Event Viewer → Windows Logs → System → Schannel logs  
- In PowerShell (check active cipher suites): 

Get-TlsCipherSuite | Select-Object Name
---

## Security Considerations

- Test before deployment: Always apply to a staging environment first.
- Verify compatibility: Some legacy applications might require older cipher suites (included in fallback position).
- Document exceptions: If any app requires weaker settings, document and risk-assess individually.

---

## Acknowledgments

- IIS Crypto: for making Schannel hardening easy and exportable.
- PDQ Connect: for streamlined remote deployment.
- OpenAI ChatGPT: for assistance in translating .ictpl files to .reg format and refining configuration.

---

## References

- [BEAST attack explained](https://en.wikipedia.org/wiki/Transport_Layer_Security#BEAST_attack)  
- [BEAST attack CVE](https://nvd.nist.gov/vuln/detail/cve-2011-3389)  
- [IIS Crypto Documentation](https://www.nartac.com/)  
- [Microsoft Schannel Registry Settings](https://www.nartac.com/Products/IISCrypto/FAQ/what-registry-keys-does-iis-crypto-modify)