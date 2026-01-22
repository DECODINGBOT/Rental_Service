package eos.lendy.global.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final StorageProperties storageProperties;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String productUrlPattern = storageProperties.getPublicUrlPrefix() + "/**";
        Path productRoot = Path.of(storageProperties.getRootLocation()).toAbsolutePath().normalize();
        String productLocation = productRoot.toUri().toString(); // "file:/.../storage/"

        registry.addResourceHandler(productUrlPattern)
                .addResourceLocations(productLocation)
                .setCachePeriod(3600);

        Path uploadRoot = Path.of("uploads").toAbsolutePath().normalize();
        String uploadLocation = uploadRoot.toUri().toString();

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(uploadLocation)
                .setCachePeriod(3600);
    }
}
