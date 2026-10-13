package com.mapfre.vida.vencimientosmanuales.infrastructure.observability;

import ch.qos.logback.classic.spi.ILoggingEvent;
import com.fasterxml.jackson.core.JsonGenerator;
import net.logstash.logback.composite.AbstractJsonProvider;

import java.io.IOException;

public class PiiMaskingMessageJsonProvider extends AbstractJsonProvider<ILoggingEvent> {
    @Override
    public void writeTo(JsonGenerator generator, ILoggingEvent event) throws IOException {
        generator.writeStringField("message", PiiMasker.mask(event.getFormattedMessage()));
    }
}
