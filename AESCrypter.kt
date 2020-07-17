class AESCrypter(key: String) {
    companion object {
        private const val INIT_VECTOR_LENGTH = 16
        private const val AES_INSTANCE = "AES/CBC/PKCS5Padding"
    }

    private var secretKeySpec: SecretKeySpec? = null

    init {
        if (!validated(key)) {
            throw GeneralSecurityException("Secret key's length must be 128, 192 or 256 bits")
        }
        val keyBytes = key.toByteArray()
        secretKeySpec = SecretKeySpec(keyBytes, "AES")
    }

    @Throws(GeneralSecurityException::class)
    fun encrypt(strToEncrypt: String): String {
        val cipher = Cipher.getInstance(AES_INSTANCE)
        val ivParameterSpec = randomIV()
        cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, ivParameterSpec)
        val encrypted = cipher.doFinal(strToEncrypt.toByteArray())
        val iv = ivParameterSpec.iv
        val byteBuffer = ByteBuffer.allocate(iv.size + encrypted.size)
        byteBuffer.put(iv)
        byteBuffer.put(encrypted)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Base64.getEncoder().encodeToString(byteBuffer.array())
        } else {
            android.util.Base64.encodeToString(byteBuffer.array(), android.util.Base64.NO_WRAP)
        }
    }

    @Throws(GeneralSecurityException::class)
    fun decrypt(strToDecrypt: String?): String {
        val cipher = Cipher.getInstance(AES_INSTANCE)
        val encrypted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Base64.getDecoder().decode(strToDecrypt)
        } else {
            android.util.Base64.decode(strToDecrypt, android.util.Base64.NO_WRAP)
        }
        val ivParameterSpec = IvParameterSpec(encrypted, 0, INIT_VECTOR_LENGTH)
        cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivParameterSpec)
        return String(cipher.doFinal(encrypted, INIT_VECTOR_LENGTH, encrypted.size - INIT_VECTOR_LENGTH))
    }
  
    private fun randomIV(): IvParameterSpec {
        val secureRandom = SecureRandom()
        val initVectorBytes = ByteArray(INIT_VECTOR_LENGTH)
        secureRandom.nextBytes(initVectorBytes)
        return IvParameterSpec(initVectorBytes)
    }
    
    private fun validated(key: String): Boolean {
        return key.length == 16 || key.length == 24 || key.length == 32
    }
}