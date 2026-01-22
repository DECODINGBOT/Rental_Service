package eos.lendy.global.storage;

import eos.lendy.global.config.StorageProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LocalStorageService implements StorageService {

    private static final Set<String> ALLOWED_EXT = Set.of("jpg", "jpeg", "png", "webp");

    private final StorageProperties props;

    @Override
    public String storeProductThumbnail(Long productId, MultipartFile file) {
        if (productId == null) throw new IllegalArgumentException("productId is required");
        if (file == null || file.isEmpty()) throw new IllegalArgumentException("file is required");

        String originalName = file.getOriginalFilename();
        String ext = extractExtension(originalName);
        if (ext == null || !ALLOWED_EXT.contains(ext)) {
            throw new IllegalArgumentException("unsupported file type");
        }

        Path root = Path.of(props.getRootLocation()).toAbsolutePath().normalize();
        Path dir = root.resolve("products")
                .resolve(String.valueOf(productId))
                .resolve("thumbnails");

        try {
            Files.createDirectories(dir);
        } catch (IOException e) {
            throw new IllegalStateException("failed to create storage directory", e);
        }

        String filename = UUID.randomUUID() + "." + ext;
        Path target = dir.resolve(filename).normalize();

        try {
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new IllegalStateException("failed to store file", e);
        }

        String publicPrefix = props.getPublicUrlPrefix();
        return publicPrefix + "/products/" + productId + "/thumbnails/" + filename;
    }

    @Override
    public void deleteProductFolder(Long productId) {
        if (productId == null) return;

        Path root = Path.of(props.getRootLocation()).toAbsolutePath().normalize();
        Path productDir = root.resolve("products").resolve(String.valueOf(productId));

        if (!Files.exists(productDir)) return;

        try {
            Files.walk(productDir)
                    .sorted((a, b) -> b.compareTo(a))
                    .forEach(p -> {
                        try {
                            Files.deleteIfExists(p);
                        } catch (IOException ignored) {}
                    });
        } catch (IOException ignored) {
            // Best-effort cleanup
        }
    }

    private String extractExtension(String filename) {
        if (!StringUtils.hasText(filename)) return null;
        String cleaned = filename.trim();
        int dot = cleaned.lastIndexOf('.');
        if (dot < 0 || dot == cleaned.length() - 1) return null;
        return cleaned.substring(dot + 1).toLowerCase();
    }
}
