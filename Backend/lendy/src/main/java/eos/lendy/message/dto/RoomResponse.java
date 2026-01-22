package eos.lendy.message.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class RoomResponse {
    private Long roomId;
    private Long transactionId;
    private Long renterId;
    private Long ownerId;
    private LocalDateTime updatedAt;
}
