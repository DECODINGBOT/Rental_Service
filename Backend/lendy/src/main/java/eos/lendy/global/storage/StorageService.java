package eos.lendy.global.storage;

import org.springframework.web.multipart.MultipartFile;

public interface StorageService {
    String storeProductThumbnail(Long productId, MultipartFile file);
    void deleteProductFolder(Long productId);
}
