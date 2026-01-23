package eos.lendy.message.websocket;

import eos.lendy.global.common.AuthUserPrincipal;
import eos.lendy.message.dto.MessageResponse;
import eos.lendy.message.dto.SendMessageRequest;
import eos.lendy.message.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class MessageWsController {

    private final MessageService messageService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/rooms/{roomId}/messages")
    public void send(
            @DestinationVariable Long roomId,
            SendMessageRequest request,
            java.security.Principal principal
    ) {
        Long userId = ((AuthUserPrincipal)
                ((org.springframework.security.core.Authentication) principal).getPrincipal()
        ).getUserId();

        MessageResponse saved = messageService.sendMessage(roomId, userId, request.getContent());

        messagingTemplate.convertAndSend("/topic/rooms/" + roomId, saved);
    }
}
