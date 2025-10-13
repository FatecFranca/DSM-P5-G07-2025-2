package com.petdex.api.application.services.websocket;

import com.petdex.api.domain.contracts.dto.websocket.BatimentoWebSocketDTO;
import com.petdex.api.domain.contracts.dto.websocket.LocalizacaoWebSocketDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.atomic.AtomicLong;

/**
 * Serviço responsável por enviar notificações em tempo real via WebSocket
 * para clientes conectados e inscritos em tópicos específicos de animais
 */
@Service
public class WebSocketNotificationService {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    // Contador para rastrear mensagens enviadas (debug)
    private final AtomicLong contadorLocalizacao = new AtomicLong(0);
    private final AtomicLong contadorBatimento = new AtomicLong(0);

    /**
     * Envia uma notificação de atualização de localização para todos os clientes
     * inscritos no tópico do animal específico
     *
     * @param animalId ID do animal
     * @param localizacaoDTO DTO contendo os dados da localização
     */
    public void enviarNotificacaoLocalizacao(String animalId, LocalizacaoWebSocketDTO localizacaoDTO) {
        long numeroMensagem = contadorLocalizacao.incrementAndGet();
        String topico = "/topic/animal/" + animalId;

        // Log ANTES de enviar
        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        System.out.println("📍 [ENVIO #" + numeroMensagem + "] Enviando notificação de localização");
        System.out.println("   Tópico: " + topico);
        System.out.println("   Animal: " + animalId);
        System.out.println("   Lat/Lng: " + localizacaoDTO.getLatitude() + ", " + localizacaoDTO.getLongitude());
        System.out.println("   Fora da área segura: " + localizacaoDTO.getIsOutsideSafeZone());
        System.out.println("   Thread: " + Thread.currentThread().getName());
        System.out.println("   StackTrace:");
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        for (int i = 2; i < Math.min(6, stackTrace.length); i++) {
            System.out.println("      " + stackTrace[i]);
        }

        messagingTemplate.convertAndSend(topico, localizacaoDTO);

        // Log DEPOIS de enviar
        System.out.println("   ✅ Mensagem enviada com sucesso!");
        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    }

    /**
     * Envia uma notificação de atualização de batimento cardíaco para todos os clientes
     * inscritos no tópico do animal específico
     *
     * @param animalId ID do animal
     * @param batimentoDTO DTO contendo os dados do batimento cardíaco
     */
    public void enviarNotificacaoBatimento(String animalId, BatimentoWebSocketDTO batimentoDTO) {
        long numeroMensagem = contadorBatimento.incrementAndGet();
        String topico = "/topic/animal/" + animalId;

        // Log ANTES de enviar
        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        System.out.println("❤️ [ENVIO #" + numeroMensagem + "] Enviando notificação de batimento");
        System.out.println("   Tópico: " + topico);
        System.out.println("   Animal: " + animalId);
        System.out.println("   Frequência: " + batimentoDTO.getFrequenciaMedia() + " BPM");
        System.out.println("   Thread: " + Thread.currentThread().getName());

        messagingTemplate.convertAndSend(topico, batimentoDTO);

        // Log DEPOIS de enviar
        System.out.println("   ✅ Mensagem enviada com sucesso!");
        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    }
}

