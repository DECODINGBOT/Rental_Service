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
        String urlPattern = storageProperties.getPublicUrlPrefix() + "/**";

        Path root = Path.of(storageProperties.getRootLocation()).toAbsolutePath().normalize();
        String location = root.toUri().toString(); // "file:/.../storage/"

        registry.addResourceHandler(urlPattern)
                .addResourceLocations(location)
                .setCachePeriod(3600);
    }
}
