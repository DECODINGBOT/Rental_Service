package eos.lendy.global.config;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(StorageProperties.class)
public class StorageConfig {

    private final StorageProperties storageProperties;

    @PostConstruct
    public void ensureRootFolderExists() throws IOException {
        Path root = Path.of(storageProperties.getRootLocation()).toAbsolutePath().normalize();
        Files.createDirectories(root);
        Files.createDirectories(root.resolve("products"));
    }
}
