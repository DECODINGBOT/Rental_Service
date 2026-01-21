package eos.lendy.global.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "storage")
public class StorageProperties {

    /**
     * Root folder on the server filesystem where uploads are stored.
     * Example: ./storage
     */
    private String rootLocation = "./storage";

    /**
     * URL prefix exposed by the server for static file access.
     * Example: /storage
     */
    private String publicUrlPrefix = "/storage";
}
