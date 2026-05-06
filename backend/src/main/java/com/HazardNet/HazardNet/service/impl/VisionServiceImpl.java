package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.VisionResponseDto;
import com.HazardNet.HazardNet.exception.AiServiceException;
import com.HazardNet.HazardNet.service.VisionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
@Slf4j
public class VisionServiceImpl implements VisionService {

    private final WebClient webClient;

    @Override
    public Integer countPeople(MultipartFile image) {
        if (image == null || image.isEmpty()) {
            throw new AiServiceException("Image file is empty or missing");
        }

        MultipartBodyBuilder builder = new MultipartBodyBuilder();
        builder.part("file", image.getResource())
                .filename(image.getOriginalFilename());

        try {
            VisionResponseDto response = webClient.post()
                    .uri("/api/count-people")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .body(BodyInserters.fromMultipartData(builder.build()))
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, clientResponse -> 
                        Mono.error(new AiServiceException("Client error while calling AI service: " + clientResponse.statusCode()))
                    )
                    .onStatus(HttpStatusCode::is5xxServerError, serverResponse -> 
                        Mono.error(new AiServiceException("AI service server error: " + serverResponse.statusCode()))
                    )
                    .bodyToMono(VisionResponseDto.class)
                    .block();

            if (response == null || response.getPeopleCount() == null) {
                throw new AiServiceException("Received empty response from AI service");
            }

            return response.getPeopleCount();
        } catch (AiServiceException e) {
            throw e;
        } catch (Exception e) {
            log.error("Unexpected error calling AI service", e);
            throw new AiServiceException("Failed to communicate with AI service: " + e.getMessage(), e);
        }
    }
}
