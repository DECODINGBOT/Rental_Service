package eos.lendy.payment.client;

import eos.lendy.payment.config.TossPaymentsProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class TossPaymentsClient {

    private final TossPaymentsProperties props;
    private final RestTemplate restTemplate = new RestTemplate();

    public Map<String, Object> confirm(String paymentKey, String orderId, Long amount) {
        String url = "https://api.tosspayments.com/v1/payments/confirm";

        HttpHeaders headers = buildAuthHeaders();

        Map<String, Object> body = Map.of(
                "paymentKey", paymentKey,
                "orderId", orderId,
                "amount", amount
        );

        try {
            ResponseEntity<Map> res = restTemplate.exchange(
                    url, HttpMethod.POST, new HttpEntity<>(body, headers), Map.class
            );
            //noinspection unchecked
            return (Map<String, Object>) res.getBody();
        } catch (RestClientResponseException e) {
            throw new IllegalArgumentException("Toss confirm failed: " + e.getResponseBodyAsString());
        }
    }

    public Map<String, Object> cancel(String paymentKey, String cancelReason, Long cancelAmount) {
        String url = "https://api.tosspayments.com/v1/payments/" + paymentKey + "/cancel";

        HttpHeaders headers = buildAuthHeaders();

        Map<String, Object> body = Map.of(
                "cancelReason", cancelReason == null ? "user_requested" : cancelReason,
                "cancelAmount", cancelAmount
        );

        try {
            ResponseEntity<Map> res = restTemplate.exchange(
                    url, HttpMethod.POST, new HttpEntity<>(body, headers), Map.class
            );
            //noinspection unchecked
            return (Map<String, Object>) res.getBody();
        } catch (RestClientResponseException e) {
            throw new IllegalArgumentException("Toss cancel failed: " + e.getResponseBodyAsString());
        }
    }

    private HttpHeaders buildAuthHeaders() {
        String raw = props.getSecretKey() + ":"; // Basic auth requires ':' suffix
        String encoded = Base64.getEncoder().encodeToString(raw.getBytes(StandardCharsets.UTF_8));

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Basic " + encoded);
        return headers;
    }
}
