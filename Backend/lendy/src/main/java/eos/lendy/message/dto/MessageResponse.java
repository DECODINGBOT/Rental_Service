package eos.lendy.message.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class MessageResponse {
    private Long id;
    private Long roomId;
    private Long senderId;
    private String content;
    private LocalDateTime sentAt;
}
