package eos.lendy.message.controller;

import eos.lendy.global.common.AuthUserPrincipal;
import eos.lendy.message.dto.MessageResponse;
import eos.lendy.message.dto.RoomResponse;
import eos.lendy.message.dto.SendMessageRequest;
import eos.lendy.message.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/messages")
public class MessageController {

    private final MessageService messageService;

    @PostMapping("/rooms/transactions/{transactionId}")
    public RoomResponse createOrGetRoom(
            @PathVariable Long transactionId,
            @AuthenticationPrincipal AuthUserPrincipal principal
    ) {
        return messageService.createOrGetRoomByTransaction(transactionId, principal.getUserId());
    }

    @GetMapping("/rooms")
    public List<RoomResponse> listRooms(@AuthenticationPrincipal AuthUserPrincipal principal) {
        return messageService.listRooms(principal.getUserId());
    }

    @GetMapping("/rooms/{roomId}")
    public List<MessageResponse> listMessages(
            @PathVariable Long roomId,
            @AuthenticationPrincipal AuthUserPrincipal principal,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime before,
            @RequestParam(required = false) Integer size
    ) {
        return messageService.listMessages(roomId, principal.getUserId(), before, size);
    }

    @PostMapping("/rooms/{roomId}")
    public MessageResponse sendMessage(
            @PathVariable Long roomId,
            @AuthenticationPrincipal AuthUserPrincipal principal,
            @RequestBody SendMessageRequest request
    ) {
        return messageService.sendMessage(roomId, principal.getUserId(), request.getContent());
    }
}
