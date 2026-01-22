package eos.lendy.global.common;

import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Objects;
import java.util.UUID;

@Component
public class FileStorageService {

    private static final Path UPLOAD_DIR = Paths.get("uploads").toAbsolutePath().normalize();

    public String save(MultipartFile file){
        if(file == null || file.isEmpty()){
            throw new IllegalArgumentException("empty file");
        }

        try{
            Files.createDirectories(UPLOAD_DIR);
            String original = Objects.toString(file.getOriginalFilename(), "file");
            String safeOriginal = original.replaceAll("[\\\\/]+", "_");
            String filename = UUID.randomUUID() + "_" + safeOriginal;
            Path dest = UPLOAD_DIR.resolve(filename).normalize();

            if(!dest.startsWith(UPLOAD_DIR)){
                throw new IllegalArgumentException("invalid filename");
            }

            try (InputStream in = file.getInputStream()){
                Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
            }

            return "/uploads/" + filename;
        } catch (Exception e){
            throw new IllegalStateException("file upload failed " + e.getMessage(), e);
        }
    }
}
