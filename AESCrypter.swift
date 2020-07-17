enum EncryptionError: Error {
    case key(String = "Invalid key length")
    case iv(String = "Invalid iv length")
    case statusCode(String = "Crypt status code unsuccessful")
    case data(String = "Invalid decryption/encryption data")
}

class AESCrypter {
    private let validKeyLengths = [kCCKeySizeAES128,
                                   kCCKeySizeAES192,
                                   kCCKeySizeAES256]
    private let ivSize = kCCBlockSizeAES128
    private let options = CCOptions(kCCOptionPKCS7Padding)
    private let algorithm = CCAlgorithm(kCCAlgorithmAES)
    private let key: Data
    
    init(key: Data) {
        self.key = key
    }
    
    func encrypt(data: Data) throws -> Data {
        let keyLength = try validated()
        let cryptLength = size_t(ivSize + data.count + ivSize)
        var cryptData = Data(count: cryptLength)
        let status = cryptData.withUnsafeMutableBytes { ivBytes in
            SecRandomCopyBytes(kSecRandomDefault, ivSize, ivBytes)
        }
        if status != 0 {
            throw EncryptionError.iv()
        }
        var numBytesEncrypted: size_t = 0
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                            algorithm,
                            options,
                            keyBytes,
                            keyLength,
                            cryptBytes,
                            dataBytes,
                            data.count,
                            (cryptBytes + ivSize),
                            cryptLength,
                            &numBytesEncrypted)
                }
            }
        }
        if Int(cryptStatus) == kCCSuccess {
            cryptData.count = numBytesEncrypted + ivSize
        } else {
            throw EncryptionError.statusCode()
        }
        return cryptData;
    }
    
    func decrypt(data: Data) throws -> Data {
        let keyLength = try validated()
        let clearLength = size_t(data.count - ivSize)
        guard clearLength >= 0 else {
            throw EncryptionError.data()
        }
        var clearData = Data(count: clearLength)
        var numBytesDecrypted: size_t = 0
        let cryptStatus = clearData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    CCCrypt(CCOperation(kCCDecrypt),
                            algorithm,
                            options,
                            keyBytes,
                            keyLength,
                            dataBytes,
                            (dataBytes + ivSize),
                            clearLength,
                            cryptBytes,
                            clearLength,
                            &numBytesDecrypted)
                }
            }
        }
        if Int(cryptStatus) == kCCSuccess {
            clearData.count = numBytesDecrypted
        }
        else {
            throw EncryptionError.statusCode()
        }
        return clearData;
    }
    
    private func validated() throws -> Int {
        let keyLength = key.count
        if (validKeyLengths.contains(keyLength) == false) {
            throw EncryptionError.key()
        }
        return keyLength
    }
}

 extension String {
    func encrypted(with key: String) throws -> Data {
        guard let keyData = key.data(using: .utf8) else {
            throw EncryptionError.key()
        }
        guard let data = self.data(using: .utf8) else {
            throw EncryptionError.data()
        }
        do {
            let crypter = AESCrypter(key: keyData)
            return try crypter.encrypt(data: data)
        } catch let error {
            throw error
        }
    }
    
    func decrypted(with key: String) throws -> String  {
        guard let keyData = key.data(using: .utf8) else {
            throw EncryptionError.key()
        }
        guard let data = self.base64Encoded else {
            throw EncryptionError.data()
        }
        do {
            let crypter = AESCrypter(key: keyData)
            guard let decrypted = try crypter.decrypt(data: data).string else {
                throw EncryptionError.statusCode()
            }
            return decrypted
        } catch let error {
            throw error
        }
    }
}

extension Data {
    var hex: String {
        return self.reduce("", { $0 + String(format: "%02x", $1) })
    }
    var string: String? {
        return String(bytes: self, encoding: .utf8)
    }
}